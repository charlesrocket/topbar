#pragma once

#include <optional>
#include <qobject.h>
#include <qqmlintegration.h>
#include <qstring.h>
#include <qstringlist.h>
#include <qtimer.h>
#include <qtmetamacros.h>
#include <qvector.h>

namespace topbar::system {

// NOLINTBEGIN(misc-include-cleaner)

class System : public QObject {
    Q_OBJECT;
    QML_ELEMENT;
    QML_SINGLETON;

    // clang-format off
    Q_PROPERTY(int cpuCores READ cpuCores CONSTANT);
    Q_PROPERTY(float cpuUsage READ cpuUsage NOTIFY cpuUsageChanged);
    Q_PROPERTY(float memoryUsage READ memoryUsage NOTIFY memoryUsageChanged);
    Q_PROPERTY(float diskUsage READ diskUsage NOTIFY diskUsageChanged);
    Q_PROPERTY(QString diskMountPoint READ diskMountPoint WRITE setDiskMountPoint NOTIFY diskMountPointChanged);
    Q_PROPERTY(int interval READ interval WRITE setPollInterval NOTIFY intervalChanged);
    Q_PROPERTY(QVariant cpuTemp READ cpuTemp NOTIFY cpuTempChanged);
    Q_PROPERTY(QVariant pchTemp READ pchTemp NOTIFY pchTempChanged);
    Q_PROPERTY(QString cpu READ cpu NOTIFY cpuChanged);
    Q_PROPERTY(QString gpu READ gpu NOTIFY gpuChanged);
    Q_PROPERTY(QStringList jails READ jails NOTIFY jailsChanged);
    // clang-format on

  public:
    explicit System(QObject *parent = nullptr);

    [[nodiscard]] QVariant cpuTemp() const;
    [[nodiscard]] QVariant pchTemp() const;
    [[nodiscard]] int cpuCores() const;
    [[nodiscard]] float cpuUsage() const;
    [[nodiscard]] float memoryUsage() const;
    [[nodiscard]] float diskUsage() const;
    [[nodiscard]] QString diskMountPoint() const;
    [[nodiscard]] int interval() const;
    [[nodiscard]] QString cpu() const;
    [[nodiscard]] QString gpu() const;
    [[nodiscard]] QStringList jails() const;

    Q_INVOKABLE void setPollInterval(int ms);
    Q_INVOKABLE void setDiskMountPoint(const QString &path);
    Q_INVOKABLE [[nodiscard]] QString uptime();

  signals:
    void cpuTempChanged();
    void pchTempChanged();
    void cpuUsageChanged();
    void memoryUsageChanged();
    void diskUsageChanged();
    void diskMountPointChanged();
    void intervalChanged();
    void cpuChanged();
    void gpuChanged();
    void jailsChanged();

  private slots:
    void poll();

  private:
    void detectCores();
    void detectCpu();
    void detectGpu();
    void updateCpu();
    void updateMemory();
    void updateDisk();
    void updateTemperatures();
    void updateJails();

    int mCpuCores = 1;
    QVector<qint64> mPrevTicks; // mCpuCores * kCpuStates
    bool mHasPrevTicks = false;

    std::optional<float> mCpuTemp;
    std::optional<float> mPchTemp;
    float mCpuUsage = 0.0f;
    float mMemoryUsage = 0.0f;
    float mDiskUsage = 0.0f;
    QString mCpu = QStringLiteral("Unknown");
    QString mGpu = QStringLiteral("Unknown");
    QString mDiskMountPoint = QStringLiteral("/");
    QStringList mJails;

    QTimer *mPollTimer = nullptr;
};

// NOLINTEND(misc-include-cleaner)

} // namespace topbar::system
