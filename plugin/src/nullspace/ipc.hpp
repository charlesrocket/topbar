#pragma once

#include <qbytearray.h>
#include <qlocalsocket.h>
#include <qobject.h>
#include <qstring.h>
#include <qtimer.h>
#include <qtmetamacros.h>

namespace topbar::nullspace {

class IpcClient : public QObject {
    Q_OBJECT

  public:
    explicit IpcClient(QObject *parent = nullptr);

    [[nodiscard]] bool isConnected() const { return this->mConnected; }

    void send(const QString &line);

  signals:
    void connectedChanged();
    void eventReceived(const QString &key, const QString &value);

  private slots:
    void onConnected();
    void onDisconnected();
    void onErrorOccurred();
    void onReadyRead();
    void tryReconnect();

  private:
    void connectSocket();
    void processLine(const QByteArray &line);

    QLocalSocket mSocket;
    QByteArray mReadBuffer;
    QTimer mReconnectTimer;
    bool mConnected = false;
};

} // namespace topbar::nullspace
