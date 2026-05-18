#pragma once

#include <QObject>
#include <QQmlEngine>
#include <QSocketNotifier>
#include <QString>
#include <QTimer>
#include <cstring>

// sbin/devd/devd.h
inline constexpr size_t devdMaxBuf = 8192;
inline constexpr int reconnectIntervalMs = 5000;
inline constexpr const char *devdPipe = "/var/run/devd.seqpacket.pipe";

namespace topbar::devd {

class Devd : public QObject {
    Q_OBJECT;
    QML_ELEMENT;
    QML_SINGLETON;
    Q_PROPERTY(bool connected READ isConnected NOTIFY connectedChanged FINAL);

  public:
    static Devd *create(QQmlEngine *engine, QJSEngine *_) {
        Q_UNUSED(engine)
        return instance();
    }

    static Devd *instance();

    ~Devd() override;

    Devd(const Devd &) = delete;
    Devd &operator=(const Devd &) = delete;
    Devd(Devd &&) = delete;
    Devd &operator=(Devd &&) = delete;

    [[nodiscard]] bool isConnected() const;

  signals:
    void eventReceived(const QString &event);
    void connectedChanged();

  private slots:
    void attemptReconnect();
    void onSocketActivated();

  private:
    explicit Devd(QObject *parent = nullptr);

    static Devd *dInstance;

    void scheduleReconnect();
    void connectToDevd();
    void onDisconnected();
    void cleanup();

    int mFd = -1;
    QSocketNotifier *mNotifier = nullptr;
    bool mConnected = false;
    QTimer *mReconnectTimer = nullptr;
};

} // namespace topbar::devd
