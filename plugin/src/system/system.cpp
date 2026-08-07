#include "system.hpp"

#include <QDBusConnection>
#include <QDBusInterface>
#include <QDBusObjectPath>
#include <QDBusReply>
#include <QDir>
#include <QFileInfo>
#include <QUrl>
#include <algorithm>
#include <limits>
#include <pwd.h>
#include <qfile.h>
#include <qglobal.h>
#include <qlogging.h>
#include <qloggingcategory.h>
#include <qobject.h>
#include <qstring.h>
#include <qstringlist.h>
#include <qtimer.h>
#include <qvariant.h>
#include <unistd.h>

// clang-format off
#ifdef __FreeBSD__
#include <array>
#include <optional>
#include <qtypes.h>
#include <sys/param.h>
#include <sys/jail.h>
#include <sys/statvfs.h>
#include <sys/sysctl.h>
#include <sys/resource.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/uio.h>
#endif
// clang-format on

namespace {

constexpr auto kAccountsService = "org.freedesktop.Accounts";
constexpr auto kAccountsPath = "/org/freedesktop/Accounts";
constexpr auto kAccountsIface = "org.freedesktop.Accounts";
constexpr auto kUserIface = "org.freedesktop.Accounts.User";

template <typename T> bool floatEq(T a, T b) {
    const T diff = std::fabs(a - b);
    if (diff <= std::numeric_limits<T>::epsilon()) { return true; }

    const T largest = std::max(std::fabs(a), std::fabs(b));
    return diff <= largest * std::numeric_limits<T>::epsilon() * T{4};
}

bool looksIntegrated(const QString &desc) {
    static const QStringList kIntegratedMarkers = {
        "HD Graphics", "UHD Graphics", "Iris",           "Vega 3",
        "Vega 6",      "Vega 8",       "Radeon Graphics"
    };

    return std::ranges::any_of(kIntegratedMarkers, [&](const QString &marker) {
        // NOLINTNEXTLINE(misc-include-cleaner)
        return desc.contains(marker, Qt::CaseInsensitive);
    });
}

} // namespace

// NOLINTBEGIN(misc-include-cleaner)

namespace topbar::system {

Q_LOGGING_CATEGORY(logSystem, "topbar.system", QtInfoMsg)

System::System(QObject *parent)
    : QObject(parent), mPollTimer(new QTimer(this)) {
#ifdef __linux__
    qCWarning(logSystem) << "Linux support is limited";
#endif

    this->detectMemory();
    this->detectCores();
    this->detectCpu();
    this->detectGpu();
#ifdef __FreeBSD__
    this->mPrevTicks.resize(qsizetype{this->mCpuCores} * CPUSTATES, 0);
#endif
    this->mPollTimer->setInterval(3000);
    this->mPollTimer->setSingleShot(false);

    connect(this->mPollTimer, &QTimer::timeout, this, &System::poll);

    this->updateCpu();
    this->updateMemory();
    this->updateDisk();
    this->updateTemperatures();
    this->updateJails();

    this->mPollTimer->start();
}

static constexpr int K_TZ_ZERO_C = 2731;

int System::interval() const { return this->mPollTimer->interval(); }
int System::installedMemory() const { return this->mInstalledMemory; }
int System::cpuCores() const { return this->mCpuCores; }
QVariant System::cpuTemp() const {
    return this->mCpuTemp ? QVariant(*this->mCpuTemp) : QVariant();
}
QVariant System::pchTemp() const {
    return this->mPchTemp ? QVariant(*this->mPchTemp) : QVariant();
}
QString System::cpu() const { return this->mCpu; }
QString System::gpu() const { return this->mGpu; }
float System::cpuUsage() const { return this->mCpuUsage; }
float System::memoryUsage() const { return this->mMemoryUsage; }
float System::diskUsage() const { return this->mDiskUsage; }
QString System::diskMountPoint() const { return this->mDiskMountPoint; }
QStringList System::jails() const { return this->mJails; }

void System::setPollInterval(int ms) {
    ms = std::max(ms, 100);
    if (this->mPollTimer->interval() != ms) {
        this->mPollTimer->setInterval(ms);
        emit this->intervalChanged();
    }
}

void System::setDiskMountPoint(const QString &path) {
    if (this->mDiskMountPoint != path) {
        this->mDiskMountPoint = path;
        emit this->diskMountPointChanged();
        this->updateDisk();
        qCInfo(logSystem) << "Mount point changed to " << path;
    }
}

void System::poll() {
    this->updateCpu();
    this->updateMemory();
    this->updateDisk();
    this->updateTemperatures();
    this->updateJails();
}

QString System::currentUserObjectPath() const {
    qint64 bufSizeHint = sysconf(_SC_GETPW_R_SIZE_MAX);
    if (bufSizeHint <= 0) { bufSizeHint = 16384; }

    std::vector<char> buf(static_cast<size_t>(bufSizeHint));
    struct passwd pwd{};
    struct passwd *result = nullptr;

    const int pwErr =
        getpwuid_r(getuid(), &pwd, buf.data(), buf.size(), &result);

    if (pwErr != 0 || !result || !result->pw_name) {
        qCWarning(logSystem)
            << "Failed to resolve current username (errno" << pwErr << ")";
        return {};
    }

    QDBusInterface accounts(
        kAccountsService, kAccountsPath, kAccountsIface,
        QDBusConnection::systemBus()
    );

    if (!accounts.isValid()) {
        qCWarning(logSystem)
            << "org.freedesktop.Accounts unavailable on system bus:"
            << accounts.lastError().message();
        return {};
    }

    const QDBusReply<QDBusObjectPath> reply = accounts.call(
        "FindUserByName", QString::fromLocal8Bit(result->pw_name)
    );

    if (!reply.isValid()) {
        qCWarning(logSystem)
            << "FindUserByName failed:" << reply.error().message();
        return {};
    }

    return reply.value().path();
}

void System::setUserIcon(const QString &path) {
    QString localPath = path;
    if (localPath.startsWith("file://")) {
        localPath = QUrl(localPath).toLocalFile();
    }

    const QFileInfo info(localPath);
    if (!info.exists() || !info.isFile()) {
        qCWarning(logSystem) << "User icon does not exist:" << localPath;
        return;
    }

    const QString absolutePath = info.absoluteFilePath();
    const QString userPath = this->currentUserObjectPath();
    if (userPath.isEmpty()) {
        qCDebug(logSystem) << "User icon is empty:" << localPath;
        return;
    }

    QDBusInterface user(
        kAccountsService, userPath, kUserIface, QDBusConnection::systemBus()
    );

    if (!user.isValid()) {
        qCWarning(logSystem) << "Failed to reach" << userPath << ":"
                             << user.lastError().message();
        return;
    }

    const QDBusReply<void> reply = user.call("SetIconFile", absolutePath);
    if (!reply.isValid()) {
        qCWarning(logSystem)
            << "SetIconFile failed:" << reply.error().message();
        return;
    }

    // mirror to `.face.icon` for tools/greeters that still read
    // it directly instead of querying AccountsService.
    const QString facePath = QDir::homePath() + "/.face.icon";
    QFile::remove(facePath);
    if (!QFile::copy(absolutePath, facePath)) {
        qCWarning(logSystem)
            << "Changed user icon via AccountsService, but failed to"
            << "mirror it to" << facePath;
    }

    qCInfo(logSystem) << "User icon updated from" << absolutePath;
    ;
}

#ifdef __FreeBSD__
QString System::uptime() {
    struct timeval boottime{};
    auto size = sizeof(boottime);

    if (sysctlbyname("kern.boottime", &boottime, &size, nullptr, 0) < 0) {
        qCWarning(logSystem) << "Failed to read kern.boottime";
        return QString();
    }

    const auto now = time(nullptr);

    if (boottime.tv_sec <= 0 || now < boottime.tv_sec) {
        qCWarning(logSystem) << "Invalid boottime reading";
        return QString();
    }

    const auto totalSeconds = static_cast<qint64>(now - boottime.tv_sec);
    const qint64 hours = totalSeconds / 3600;
    const int minutes = static_cast<int>((totalSeconds % 3600) / 60);

    return QString("%1:%2")
        .arg(hours, 2, 10, QChar('0'))
        .arg(minutes, 2, 10, QChar('0'));
}
#endif

#ifdef __FreeBSD__
namespace {

struct GpuCandidate {
    QString description;
    int bus = -1;
    bool isVgaController = false; // subclass 0x00 vs 0x02 (3D controller)
};

#include <cerrno>
#include <cstdlib>
#include <cstring>
#include <string>

std::optional<int> parseBus(const std::string &header) {
    // "vgapci0@pci0:0:2:0:"
    const auto pos = header.find("@pci");
    if (pos == std::string::npos) return std::nullopt;

    const char *afterPci =
        std::next(header.c_str(), static_cast<std::ptrdiff_t>(pos + 4));

    const char *colon1 = std::strchr(afterPci, ':');
    if (!colon1) return std::nullopt;

    const char *busStart = std::next(colon1, 1);

    errno = 0;
    char *endPtr = nullptr;
    const qint64 bus = std::strtol(busStart, &endPtr, 10);

    if (endPtr == busStart) return std::nullopt; // no digits found
    if (errno == ERANGE || bus < std::numeric_limits<int>::min()
        || bus > std::numeric_limits<int>::max()) {
        return std::nullopt; // out of int range
    }

    return static_cast<int>(bus);
}

QString trimQuotes(std::string s) {
    // "'Foo Corporation'" -> "Foo Corporation"
    if (s.size() >= 2 && s.front() == '\'' && s.back() == '\'') {
        s = s.substr(1, s.size() - 2);
    }
    return QString::fromStdString(s);
}

} // namespace

void System::detectGpu() {
    FILE *pipe = popen("pciconf -lv 2>/dev/null", "r");
    if (!pipe) {
        qCWarning(logSystem) << "Failed to run pciconf";
        return;
    }

    std::vector<GpuCandidate> found;
    GpuCandidate current;
    QString vendorName, deviceName, className, subclassName;
    bool inBlock = false;

    std::array<char, 512> lineBuf{};
    auto flushBlock = [&]() {
        if (inBlock && (className == "display")) {
            current.isVgaController = (subclassName == "VGA");
            QString desc = vendorName;

            if (!deviceName.isEmpty()) {
                if (!desc.isEmpty()) desc += " ";
                desc += deviceName;
            }

            if (!desc.isEmpty()) {
                current.description = desc;
                found.push_back(current);
                qCInfo(logSystem) << "Detected GPU:" << current.description
                                  << "bus" << current.bus;
            }
        }

        inBlock = false;
        vendorName.clear();
        deviceName.clear();
        className.clear();
        subclassName.clear();
    };

    while (std::fgets(lineBuf.data(), lineBuf.size(), pipe)) {
        std::string line(lineBuf.data());
        // new device block starts with a non-indented line containing "@pci"
        if (!line.empty() && !std::isspace(static_cast<unsigned char>(line[0]))
            && line.find("@pci") != std::string::npos) {
            flushBlock();
            inBlock = true;
            current = GpuCandidate{};
            if (auto bus = parseBus(line)) { current.bus = *bus; }
            continue;
        }

        if (!inBlock) continue;

        auto extract = [&](const char *key) -> std::optional<std::string> {
            const auto pos = line.find(key);
            if (pos == std::string::npos) return std::nullopt;
            auto eq = line.find('=', pos);
            if (eq == std::string::npos) return std::nullopt;
            std::string val = line.substr(eq + 1);
            // trim whitespace/newline
            while (!val.empty()
                   && std::isspace(static_cast<unsigned char>(val.back())))
                val.pop_back();
            size_t start = 0;
            while (start < val.size()
                   && std::isspace(static_cast<unsigned char>(val[start])))
                ++start;
            return val.substr(start);
        };

        // TODO trim whitespaces
        if (auto v = extract("vendor     "))
            vendorName = trimQuotes(*v);
        else if (auto d = extract("device     "))
            deviceName = trimQuotes(*d);
        else if (auto c = extract("class      "))
            className = QString::fromStdString(*c).trimmed();
        else if (auto sc = extract("subclass   "))
            subclassName = QString::fromStdString(*sc).trimmed();
    }

    flushBlock();
    pclose(pipe);

    if (found.empty()) {
        qCWarning(logSystem) << "Failed to detect GPU";
        return;
    }

    // prefer discrete (non-zero bus)
    const GpuCandidate *main = &found.front();
    for (const auto &cand : found) {
        const bool candBetter =
            // prefer non-VGA-primary + non-integrated-looking description
            (!looksIntegrated(cand.description)
             && looksIntegrated(main->description))
            ||
            // if integration-status is ambiguous, prefer the active VGA
            // controller
            (looksIntegrated(cand.description)
                 == looksIntegrated(main->description)
             && cand.isVgaController && !main->isVgaController)
            ||
            // last resort: higher bus number
            (looksIntegrated(cand.description)
                 == looksIntegrated(main->description)
             && cand.isVgaController == main->isVgaController
             && cand.bus > main->bus);

        if (candBetter) main = &cand;
    }

    this->mGpu = main->description;
    qCDebug(logSystem) << "Main GPU:" << this->mGpu;
}
#endif
#ifdef __FreeBSD__
void System::detectMemory() {
    quint64 mem = 0;
    auto size = sizeof(mem);

    if (sysctlbyname("hw.physmem", &mem, &size, nullptr, 0) == 0 && mem > 0) {
        constexpr quint64 kGiB = 1024ULL * 1024ULL * 1024ULL;
        this->mInstalledMemory = static_cast<int>((mem + kGiB / 2) / kGiB);
        qCInfo(logSystem) << "Detected memory:" << this->mInstalledMemory
                          << "GB";
    } else {
        qCWarning(logSystem) << "Failed to read hw.physmem";
    }
}
#endif

#ifdef __FreeBSD__
void System::detectCores() {
    auto cores = 0;
    auto size = sizeof(cores);

    if (sysctlbyname("hw.ncpu", &cores, &size, nullptr, 0) == 0 && cores > 0) {
        this->mCpuCores = cores;
        qCInfo(logSystem) << "Detected CPU cores:" << cores;
    } else {
        qCWarning(logSystem) << "Failed to read hw.ncpu, defaulting to 1";
    }
}
#endif

#ifdef __FreeBSD__
void System::detectCpu() {
    std::array<char, 256> buf{};
    auto bufLen = buf.size();

    if (sysctlbyname("hw.model", buf.data(), &bufLen, nullptr, 0) == 0
        && bufLen > 0) {
        this->mCpu =
            QString::fromLocal8Bit(buf.data(), static_cast<int>(bufLen - 1));
        qCInfo(logSystem) << "Detected CPU:" << this->mCpu;
    } else {
        qCWarning(logSystem) << "Failed to read hw.model";
    }
}
#endif

#ifdef __FreeBSD__
void System::updateCpu() {
    const auto wantedBytes =
        static_cast<size_t>(this->mCpuCores * CPUSTATES) * sizeof(qint64);

    auto ticks = QVector<qint64>(this->mCpuCores * CPUSTATES, 0);
    auto returnedBytes = wantedBytes;

    if (sysctlbyname("kern.cp_times", ticks.data(), &returnedBytes, nullptr, 0)
        < 0) {
        qCWarning(logSystem) << "Failed to read kern.cp_times";
        return;
    }

    const auto validCores =
        static_cast<int>(returnedBytes / sizeof(qint64)) / CPUSTATES;

    if (validCores <= 0) { return; }

    if (!this->mHasPrevTicks) {
        this->mPrevTicks = ticks;
        this->mHasPrevTicks = true;
        return;
    }

    qint64 totalDelta = 0;
    qint64 idleDelta = 0;

    for (auto core = 0; core < validCores; core++) {
        const auto base = core * CPUSTATES;

        qint64 coreTotalDelta = 0;
        qint64 coreIdleDelta = 0;

        for (auto state = 0; state < CPUSTATES; state++) {
            const auto delta =
                ticks[base + state] - this->mPrevTicks[base + state];

            if (delta < 0) {
                coreTotalDelta = 0;
                coreIdleDelta = 0;
                break;
            }

            coreTotalDelta += delta;
            if (state == CP_IDLE) { coreIdleDelta = delta; }
        }

        totalDelta += coreTotalDelta;
        idleDelta += coreIdleDelta;
    }

    this->mPrevTicks = ticks;

    if (totalDelta <= 0) { return; }

    const auto newUsage = std::clamp(
        static_cast<float>(totalDelta - idleDelta)
            / static_cast<float>(totalDelta),
        0.0f, 1.0f
    );

    if (!floatEq(this->mCpuUsage, newUsage)) {
        this->mCpuUsage = newUsage;
        emit this->cpuUsageChanged();
    }
}
#endif

#ifdef __FreeBSD__
void System::updateMemory() {
    auto totalPages = 0u;
    auto size = sizeof(totalPages);

    if (sysctlbyname("vm.stats.vm.v_page_count", &totalPages, &size, nullptr, 0)
        < 0) {
        qCWarning(logSystem) << "Failed to read vm.stats.vm.v_page_count";
        return;
    }

    if (totalPages == 0) { return; }

    auto activePages = 0u;
    auto wiredPages = 0u;
    auto laundryPages = 0u;

    size = sizeof(activePages);
    if (sysctlbyname(
            "vm.stats.vm.v_active_count", &activePages, &size, nullptr, 0
        )
        < 0) {
        qCWarning(logSystem) << "Failed to read vm.stats.vm.v_active_count";
        return;
    }

    size = sizeof(wiredPages);
    if (sysctlbyname("vm.stats.vm.v_wire_count", &wiredPages, &size, nullptr, 0)
        < 0) {
        qCWarning(logSystem) << "Failed to read vm.stats.vm.v_wire_count";
        return;
    }

    size = sizeof(laundryPages);
    if (sysctlbyname(
            "vm.stats.vm.v_laundry_count", &laundryPages, &size, nullptr, 0
        )
        < 0) {
        qCWarning(logSystem) << "Failed to read vm.stats.vm.v_laundry_count";
        return;
    }

    const auto usedPages = activePages + wiredPages + laundryPages;

    const auto newUsage = std::clamp(
        static_cast<float>(usedPages) / static_cast<float>(totalPages), 0.0f,
        1.0f
    );

    if (!floatEq(this->mMemoryUsage, newUsage)) {
        this->mMemoryUsage = newUsage;
        emit this->memoryUsageChanged();
    }
}
#endif

#ifdef __FreeBSD__
void System::updateDisk() {
    struct statvfs st{};

    // statvfs(2): f_blocks is total blocks, f_bfree is free blocks (incl. root
    // reserved), f_bavail is free blocks available to unprivileged processes.
    if (statvfs(this->mDiskMountPoint.toLocal8Bit().constData(), &st) != 0) {
        qCWarning(logSystem) << "statvfs failed for" << this->mDiskMountPoint;
        return;
    }

    if (st.f_blocks == 0) { return; }

    // usable total = f_blocks - (f_bfree - f_bavail) [root-reserved blocks]
    // we use f_bavail so the value reflects what the user can actually use
    const auto total =
        static_cast<float>(st.f_blocks - (st.f_bfree - st.f_bavail));

    // guard against non-positive denominator
    // (filesystem corruption/fully reserved volume)
    if (total <= 0.0f) {
        constexpr float full = 1.0f;
        if (!floatEq(this->mDiskUsage, full)) {
            this->mDiskUsage = full;
            emit this->diskUsageChanged();
        }

        qCDebug(logSystem) << "Total usable disk blocks is non-positive";

        return;
    }

    const auto avail = static_cast<float>(st.f_bavail);
    const auto newUsage = std::clamp(1.0f - avail / total, 0.0f, 1.0f);

    if (!floatEq(this->mDiskUsage, newUsage)) {
        this->mDiskUsage = newUsage;
        emit this->diskUsageChanged();
    }
}
#endif

#ifdef __FreeBSD__
std::optional<float> readTempC(const char *oid) {
    int raw = 0;
    auto size = sizeof(raw);
    if (sysctlbyname(oid, &raw, &size, nullptr, 0) < 0) { return std::nullopt; }

    // raw <= K_TZ_ZERO_C means 0°C or below
    // (sensor uninitialised or broken)
    if (raw <= K_TZ_ZERO_C) { return std::nullopt; }

    const float temp = static_cast<float>(raw - K_TZ_ZERO_C) / 10.0f;
    return std::optional<float>(temp);
}
#endif

#ifdef __FreeBSD__
void System::updateTemperatures() {
    const auto newCpuTemp = readTempC("hw.acpi.thermal.tz0.temperature");
    if (this->mCpuTemp != newCpuTemp) {
        this->mCpuTemp = newCpuTemp;
        emit this->cpuTempChanged();
    }

    const auto newPchTemp = readTempC("dev.pchtherm.0.temperature");
    if (this->mPchTemp != newPchTemp) {
        this->mPchTemp = newPchTemp;
        emit this->pchTempChanged();
    }
}
#endif

#ifdef __FreeBSD__
void System::updateJails() {
    QStringList newJails;
    int lastJid = 0;

    while (true) {
        int jid = 0;
        std::array<char, MAXHOSTNAMELEN> name{};

        static std::array<char, 8> kLastJid = {"lastjid"};
        static std::array<char, 4> kJid = {"jid"};
        static std::array<char, 5> kName = {"name"};

        std::array<struct iovec, 6> iov = {
            {
             {.iov_base = kLastJid.data(), .iov_len = kLastJid.size()},
             {.iov_base = &lastJid, .iov_len = sizeof(lastJid)},
             {.iov_base = kJid.data(), .iov_len = kJid.size()},
             {.iov_base = &jid, .iov_len = sizeof(jid)},
             {.iov_base = kName.data(), .iov_len = kName.size()},
             {.iov_base = name.data(), .iov_len = name.size()},
             }
        };

        const int ret =
            ::jail_get(iov.data(), static_cast<u_int>(iov.size()), 0);

        if (ret < 0) {
            if (errno != ENOENT) { qCWarning(logSystem) << "jail_get failed"; }

            break;
        }

        lastJid = ret;
        newJails.append(QString::fromLocal8Bit(name.data()));
    }

    if (this->mJails != newJails) {
        this->mJails = newJails;
        emit this->jailsChanged();
    }
}
#endif

// NOLINTEND(misc-include-cleaner)

} // namespace topbar::system
