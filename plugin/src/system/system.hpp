#pragma once

#include <qobject.h>
#include <qqmlintegration.h>
#include <qstring.h>
#include <qtimer.h>
#include <qtmetamacros.h>
#include <qtypes.h>
#include <qvector.h>

namespace topbar::system {

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
    Q_PROPERTY(int interval READ interval WRITE setInterval NOTIFY intervalChanged);
    Q_PROPERTY(float cpuTemp READ cpuTemp NOTIFY cpuTempChanged);
    Q_PROPERTY(float pchTemp READ pchTemp NOTIFY pchTempChanged);
    Q_PROPERTY(QStringList jails READ jails NOTIFY jailsChanged);
    // clang-format on

  public:
    explicit System(QObject *parent = nullptr);

    [[nodiscard]] float cpuTemp() const;
    [[nodiscard]] float pchTemp() const;
    [[nodiscard]] int cpuCores() const;
    [[nodiscard]] float cpuUsage() const;
    [[nodiscard]] float memoryUsage() const;
    [[nodiscard]] float diskUsage() const;
    [[nodiscard]] QString diskMountPoint() const;
    [[nodiscard]] int interval() const;
    [[nodiscard]] QStringList jails() const;

    void setInterval(int ms);
    void setDiskMountPoint(const QString &path);

  signals:
    void cpuTempChanged();
    void pchTempChanged();
    void cpuUsageChanged();
    void memoryUsageChanged();
    void diskUsageChanged();
    void diskMountPointChanged();
    void intervalChanged();
    void jailsChanged();

  private slots:
    void poll();

  private:
    void detectCores();
    void updateCpu();
    void updateMemory();
    void updateDisk();
    void updateTemperatures();
    void updateJails();

    // FreeBSD kern.cp_times has CPUSTATES ticks per core. CPUSTATES == 5:
    // CP_USER, CP_NICE, CP_SYS, CP_INTR, CP_IDLE.
    static constexpr int kCpuStates = 5;

    int mCpuCores = 1;
    QVector<qint64> mPrevTicks; // mCpuCores * kCpuStates
    bool mHasPrevTicks = false;

    float mCpuTemp = -1.0f;
    float mPchTemp = -1.0f;
    float mCpuUsage = 0.0f;
    float mMemoryUsage = 0.0f;
    float mDiskUsage = 0.0f;
    QString mDiskMountPoint = QStringLiteral("/");
    QStringList mJails;

    QTimer *mPollTimer = nullptr;
};

} // namespace topbar::system
