#pragma once

#include <qbytearray.h>
#include <qobject.h>
#include <qqmlintegration.h>
#include <qsocketnotifier.h>
#include <qstring.h>
#include <qtmetamacros.h>

namespace topbar::devd {

class Devd : public QObject {
    Q_OBJECT;
    QML_ELEMENT;
    QML_SINGLETON;

    Q_PROPERTY(bool connected READ isConnected NOTIFY connectedChanged);

  public:
    explicit Devd(QObject *parent = nullptr);
    ~Devd() override;

    Q_DISABLE_COPY_MOVE(Devd);

    [[nodiscard]] bool isConnected() const;

  signals:
    void eventReceived(const QString &event);
    void connectedChanged();

  private slots:
    void onSocketActivated();

  private:
    void connectToDevd();
    void cleanup();

    int mFd = -1;
    QSocketNotifier *mNotifier = nullptr;
    bool mConnected = false;
    QByteArray mBuffer;
};

} // namespace topbar::devd
