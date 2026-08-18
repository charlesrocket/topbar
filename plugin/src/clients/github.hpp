#pragma once

#include <QDateTime>
#include <QList>
#include <QLoggingCategory>
#include <QNetworkRequestFactory>
#include <QOAuth2DeviceAuthorizationFlow>
#include <QObject>
#include <QRestAccessManager>
#include <QRestReply>
#include <QSet>
#include <QSettings>
#include <QString>
#include <QStringLiteral>
#include <QTimer>
#include <QVariantList>
#include <QVariantMap>
#include <qnetworkaccessmanager.h>
#include <qqmlintegration.h>

namespace topbar::clients {

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
    QML_ELEMENT
    Q_OBJECT

    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(bool authenticated READ authenticated NOTIFY authenticatedChanged
    )
    Q_PROPERTY(int pollIntervalSeconds READ pollIntervalSeconds WRITE
                   setPollIntervalSeconds NOTIFY pollIntervalSecondsChanged)
    Q_PROPERTY(QVariantList notifications READ notificationsVariant NOTIFY
                   notificationsUpdated)

  public:
    explicit GitHub(QObject *parent = nullptr);
    ~GitHub() override;

    GitHub(const GitHub &) = delete;
    GitHub &operator=(const GitHub &) = delete;
    GitHub(GitHub &&) = delete;
    GitHub &operator=(GitHub &&) = delete;

    void setEnabled(bool value);

    [[nodiscard]] bool enabled() const;
    [[nodiscard]] bool authenticated() const;

    [[nodiscard]] int pollIntervalSeconds() const;
    void setPollIntervalSeconds(int seconds);

    [[nodiscard]] QVariantList notificationsVariant() const;

    Q_INVOKABLE void login();
    Q_INVOKABLE void logout();
    Q_INVOKABLE void refresh();
    Q_INVOKABLE void markAsRead(const QString &threadId);
    Q_INVOKABLE void markAllAsRead();

  signals:
    void enabledChanged();
    void authenticatedChanged();
    void pollIntervalSecondsChanged();
    void notificationsUpdated();
    void deviceAuthorizationRequired(
        const QString &verificationUrl, const QString &userCode
    );

    void error(const QString &message);

  private:
    void start();
    void stop();

    void setupApi();
    void setupOAuth();

    void loadNotificationCache();
    void loadOAuthTokens();

    void onOAuthGranted();
    void onOAuthDeauthenticated();

    void persistSeenIds();
    void persistLastPoll();

    void poll();
    void handleNotificationsReply(QRestReply &reply);
    void spawnNotification(const GHNotification &notification) const;

    QSettings settings;
    QNetworkAccessManager *qnam = nullptr;
    QOAuth2DeviceAuthorizationFlow *oauth2 = nullptr;
    QRestAccessManager *network = nullptr;
    QNetworkRequestFactory api;

    QTimer pollTimer;

    QList<GHNotification> current;
    QSet<QString> seenIds;
    QString lastModified;
    QString etag;

    bool mEnabled = false;
    bool mAuthenticated = false;
};

} // namespace topbar::clients
