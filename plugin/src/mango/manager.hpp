#pragma once

#include "output.hpp"

#include <QtGlobal>
#include <qbytearray.h>
#include <qhash.h>
#include <qjsonobject.h>
#include <qlist.h>
#include <qlocalsocket.h>
#include <qloggingcategory.h>
#include <qobject.h>
#include <qscreen.h>
#include <qstring.h>
#include <qstringlist.h>
#include <qtimer.h>
#include <qtmetamacros.h>

Q_DECLARE_LOGGING_CATEGORY(logMangoIpc)

namespace topbar::mango {

class MangoIpcManager : public QObject {
    Q_OBJECT;

  public:
    explicit MangoIpcManager();

    [[nodiscard]] quint32 tagCount() const;
    [[nodiscard]] QStringList layouts() const;
    [[nodiscard]] QList<MangoIpcOutput *> outputs() const;
    [[nodiscard]] bool isActive() const;

    quint32 indexForLayoutSymbol(const QString &symbol);

    void sendCommand(const QString &line);

    static MangoIpcManager *instance();

  signals:
    void tagCountChanged();
    void layoutsChanged();
    void outputAdded(MangoIpcOutput *output);
    void outputRemoved(MangoIpcOutput *output);
    void activeChanged();

  private slots:
    void onSocketConnected();
    void onSocketDisconnected();
    void onSocketErrorOccurred();
    void onSocketReadyRead();
    void reconnect();
    void requestLayouts();
    void onScreenAdded(QScreen *screen);
    void onScreenRemoved(QScreen *screen);

  private:
    MangoIpcOutput *outputForName(const QString &name, bool createIfMissing);
    void handleMonitorObject(const QJsonObject &monitor);
    void handleTopLevelMessage(const QJsonObject &root);
    void processLine(const QByteArray &line);
    void setLayouts(const QStringList &layouts);
    void connectSocket();

    QLocalSocket mSocket;
    QByteArray mReadBuffer;
    QTimer mReconnectTimer;
    bool mConnected = false;

    quint32 mTagCount = 0;
    QStringList mLayouts;
    QList<MangoIpcOutput *> mOutputs;
    QHash<QString, MangoIpcOutput *> mOutputMap;
};

} // namespace topbar::mango
