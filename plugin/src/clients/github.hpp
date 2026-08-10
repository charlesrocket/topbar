#pragma once

#include <QDateTime>
#include <QJsonObject>
#include <QList>
#include <QNetworkAccessManager>
#include <QNetworkRequestFactory>
#include <QOAuth2DeviceAuthorizationFlow>
#include <QSet>
#include <QSettings>
#include <QString>
#include <QTimer>
#include <QVariantList>
#include <qqmlintegration.h>

QT_FORWARD_DECLARE_CLASS(QRestAccessManager)
QT_FORWARD_DECLARE_CLASS(QRestReply)

namespace topbar::Clients {

struct GHNotification {
    QString id;
    QString reason;
    QString subjectTitle;
    QString subjectType;
    QString repoFullName;
    QString htmlUrl;
    QDateTime updatedAt;
    bool unread = true;

    [[nodiscard]] QVariantMap toVariantMap() const;
};

class GitHub : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    // clang-format off
    Q_PROPERTY(bool authenticated READ isAuthenticated NOTIFY authenticatedChanged)
    Q_PROPERTY(int pollIntervalSeconds READ pollIntervalSeconds WRITE setPollIntervalSeconds NOTIFY pollIntervalSecondsChanged)
    Q_PROPERTY(QVariantList notifications READ notificationsVariant NOTIFY notificationsUpdated)
    // clang-format on

  public:
    static GitHub *
    create(QQmlEngine *engine, QJSEngine * /*_*/ /*_*/ /*_*/ /*_*/) {
        Q_UNUSED(engine)
        return instance();
    }

    static GitHub *instance();

    ~GitHub() override;
    GitHub(const GitHub &) = delete;
    GitHub &operator=(const GitHub &) = delete;
    GitHub(GitHub &&) = delete;
    GitHub &operator=(GitHub &&) = delete;

    [[nodiscard]] bool isAuthenticated() const { return authenticated; }
    [[nodiscard]] int pollIntervalSeconds() const {
        return pollTimer.interval() / 1000;
    }
    void setPollIntervalSeconds(int seconds);
    [[nodiscard]] QVariantList notificationsVariant() const;

    Q_INVOKABLE void login();
    Q_INVOKABLE void logout();
    Q_INVOKABLE void refresh();
    Q_INVOKABLE void markAsRead(const QString &threadId);
    Q_INVOKABLE void markAllAsRead();

  signals:
    void error(const QString &errorString);
    void authenticatedChanged();
    void pollIntervalSecondsChanged();
    void notificationsUpdated();
    void deviceAuthorizationRequired(
        const QString &verificationUrl, const QString &userCode
    );

  private:
    explicit GitHub(QObject *parent = nullptr);

    void setupApi();
    void setupOAuth();
    void applyToken(const QString &accessToken);

    void loadPersistedState();
    void persistSeenIds();
    void persistLastPoll();

    void poll();
    void handleNotificationsReply(QRestReply &reply);
    void spawnNotification(const GHNotification &notification) const;

    static GitHub *gInstance;

    QString clientId;
    QString clientSecret;
    QNetworkAccessManager *qnam = nullptr;
    QRestAccessManager *network = nullptr;
    QNetworkRequestFactory api;
    QOAuth2DeviceAuthorizationFlow oauth2;

    QTimer pollTimer;
    QSettings settings;

    QSet<QString> seenIds;
    QList<GHNotification> current;
    QString lastModified;
    QString etag;

    bool authenticated = false;
};

} // namespace topbar::Clients
