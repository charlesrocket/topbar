#pragma once

#include <QDateTime>
#include <QList>
#include <QLoggingCategory>
#include <QNetworkRequestFactory>
#include <QOAuth2AuthorizationCodeFlow>
#include <QOAuthHttpServerReplyHandler>
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

struct CBNotification {
    QString id;
    QString subjectTitle;
    QString subjectType;
    QString subjectState;
    QString repoFullName;
    QString htmlUrl;
    QDateTime updatedAt;
    bool unread = true;
    bool pinned = false;

    [[nodiscard]] QVariantMap toVariantMap() const;
};

class Codeberg : public QObject {
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
    explicit Codeberg(QObject *parent = nullptr);
    ~Codeberg() override;

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

    void authorizationRequired(const QString &authorizationUrl);
    void error(const QString &message);

  private:
    void start();
    void stop();

    void setupApi();
    void setupOAuth();

    void loadOAuthTokens();
    void onOAuthGranted();
    void onOAuthDeauthenticated();

    void loadNotificationCache();
    void persistSeenIds();
    void poll();

    void handleNotificationsReply(QRestReply &reply);
    void spawnNotification(const CBNotification &notification) const;

    QSettings settings;
    QNetworkAccessManager *qnam = nullptr;
    QOAuth2AuthorizationCodeFlow *oauth2 = nullptr;
    QOAuthHttpServerReplyHandler *replyHandler = nullptr;
    QRestAccessManager *network = nullptr;
    QNetworkRequestFactory api;
    QTimer pollTimer;

    QList<CBNotification> current;
    QSet<QString> seenIds;

    bool mEnabled = false;
    bool mAuthenticated = false;
};

} // namespace topbar::clients
