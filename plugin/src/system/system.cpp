#include "system.hpp"

#include <algorithm>
#include <qlogging.h>
#include <qloggingcategory.h>
#include <qtimer.h>
#include <qvector.h>
#include <sys/statvfs.h>
#include <sys/sysctl.h>
#include <sys/types.h>

namespace topbar::system {

Q_LOGGING_CATEGORY(logSystem, "topbar.system")

System::System(QObject *parent)
    : QObject(parent), mPollTimer(new QTimer(this)) {
    this->detectCores();

    this->mPrevTicks.resize(this->mCpuCores * kCpuStates, 0);
    this->mPollTimer->setInterval(3000);
    this->mPollTimer->setSingleShot(false);

    connect(this->mPollTimer, &QTimer::timeout, this, &System::poll);

    this->updateCpu();
    this->updateMemory();
    this->updateDisk();

    this->mPollTimer->start();
}

static constexpr int kTzZeroC = 2731;

int System::cpuCores() const { return this->mCpuCores; }
float System::cpuTemp() const { return this->mCpuTemp; }
float System::pchTemp() const { return this->mPchTemp; }
float System::cpuUsage() const { return this->mCpuUsage; }
float System::memoryUsage() const { return this->mMemoryUsage; }
float System::diskUsage() const { return this->mDiskUsage; }
QString System::diskMountPoint() const { return this->mDiskMountPoint; }
int System::interval() const { return this->mPollTimer->interval(); }

void System::setInterval(int ms) {
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
    }
}

void System::poll() {
    this->updateCpu();
    this->updateMemory();
    this->updateDisk();
    this->updateTemperatures();
}

void System::detectCores() {
    auto cores = 0;
    auto size = sizeof(cores);

    if (sysctlbyname("hw.ncpu", &cores, &size, nullptr, 0) == 0 && cores > 0) {
        this->mCpuCores = cores;
        qCInfo(logSystem) << "Detected" << cores << "CPU core(s)";
    } else {
        qCWarning(logSystem) << "Failed to read hw.ncpu, defaulting to 1";
    }
}

void System::updateCpu() {
    const auto wantedBytes =
        static_cast<size_t>(this->mCpuCores * kCpuStates) * sizeof(qint64);

    auto ticks = QVector<qint64>(this->mCpuCores * kCpuStates, 0);
    auto returnedBytes = wantedBytes;

    if (sysctlbyname("kern.cp_times", ticks.data(), &returnedBytes, nullptr, 0)
        < 0) {
        qCWarning(logSystem) << "Failed to read kern.cp_times";
        return;
    }

    const auto validCores =
        static_cast<int>(returnedBytes / sizeof(qint64)) / kCpuStates;

    if (validCores <= 0) { return; }

    if (!this->mHasPrevTicks) {
        this->mPrevTicks = ticks;
        this->mHasPrevTicks = true;
        return;
    }

    qint64 totalDelta = 0;
    qint64 idleDelta = 0;

    for (auto core = 0; core < validCores; core++) {
        const auto base = core * kCpuStates;

        qint64 coreTotalDelta = 0;
        qint64 coreIdleDelta = 0;

        for (auto state = 0; state < kCpuStates; state++) {
            const auto delta =
                ticks[base + state] - this->mPrevTicks[base + state];

            if (delta < 0) {
                coreTotalDelta = 0;
                coreIdleDelta = 0;
                break;
            }

            coreTotalDelta += delta;
            if (state == 4) { coreIdleDelta = delta; } // CP_IDLE
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

    if (this->mCpuUsage != newUsage) {
        this->mCpuUsage = newUsage;
        emit this->cpuUsageChanged();
    }
}

void System::updateMemory() {
    auto totalPages = 0u;
    auto size = sizeof(totalPages);

    if (sysctlbyname("vm.stats.vm.v_page_count", &totalPages, &size, nullptr, 0)
        < 0) {
        qCWarning(logSystem) << "Failed to read vm.stats.vm.v_page_count";
        return;
    }

    if (totalPages == 0) { return; }

    auto freePages = 0u;
    auto inactivePages = 0u;

    size = sizeof(freePages);

    sysctlbyname("vm.stats.vm.v_free_count", &freePages, &size, nullptr, 0);

    size = sizeof(inactivePages);

    sysctlbyname(
        "vm.stats.vm.v_inactive_count", &inactivePages, &size, nullptr, 0
    );

    const auto availablePages = freePages + inactivePages;
    const auto usedPages =
        totalPages > availablePages ? totalPages - availablePages : 0u;

    const auto newUsage = std::clamp(
        static_cast<float>(usedPages) / static_cast<float>(totalPages), 0.0f,
        1.0f
    );

    if (this->mMemoryUsage != newUsage) {
        this->mMemoryUsage = newUsage;
        emit this->memoryUsageChanged();
    }
}

void System::updateDisk() {
    struct statvfs st{};

    // statvfs(2): f_blocks is total blocks, f_bfree is free blocks (incl. root
    // reserved), f_bavail is free blocks available to unprivileged processes.
    // We use f_bavail so the bar reflects what the user can actually use.
    if (::statvfs(this->mDiskMountPoint.toLocal8Bit().constData(), &st) != 0) {
        qCWarning(logSystem) << "statvfs failed for" << this->mDiskMountPoint;
        return;
    }

    if (st.f_blocks == 0) { return; }

    // Usable total = f_blocks - (f_bfree - f_bavail)  [root-reserved blocks]
    const auto total =
        static_cast<float>(st.f_blocks - (st.f_bfree - st.f_bavail));

    const auto avail = static_cast<float>(st.f_bavail);
    const auto newUsage = std::clamp(1.0f - avail / total, 0.0f, 1.0f);

    if (this->mDiskUsage != newUsage) {
        this->mDiskUsage = newUsage;
        emit this->diskUsageChanged();
    }
}

void System::updateTemperatures() {
    const auto readTempC = [](const char *oid) -> float {
        int raw = 0;
        auto size = sizeof(raw);

        if (sysctlbyname(oid, &raw, &size, nullptr, 0) < 0) {
            return -1.0f; // sensor module not loaded or OID absent
        }

        // raw <= kTzZeroC means 0 °C or below — sensor uninitialised or broken
        // (a running CPU will never genuinely be at 0 °C or below)
        if (raw <= kTzZeroC) { return -1.0f; }
        return static_cast<float>(raw - kTzZeroC) / 10.0f;
    };

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

} // namespace topbar::system
