#include "github.hpp"

#include <QAbstractOAuth2>
#include <QByteArray>
#include <QDesktopServices>
#include <QHttpHeaders>
#include <QJsonArray>
#include <QJsonDocument>
#include <QList>
#include <QLoggingCategory>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QOAuth2DeviceAuthorizationFlow>
#include <QProcess>
#include <QRestAccessManager>
#include <QRestReply>
#include <QString>
#include <QTimer>
#include <QUrlQuery>

namespace {
using namespace Qt::StringLiterals;

constexpr char APIBASEURL[23] = "https://api.github.com";
constexpr char NOTIFICATIONSPATH[15] = "/notifications";
constexpr char DEVICECODEURL[37] = "https://github.com/login/device/code";
constexpr char ACCESSTOKENURL[44] =
    "https://github.com/login/oauth/access_token";
constexpr int DEFAULTPOLLINTERVALSEC = 90;
constexpr int MINPOLLINTERVALSEC = 60;

QString envOrEmpty(const char *name) {
    return QString::fromUtf8(qgetenv(name));
}

} // namespace

namespace topbar::Clients {

Q_LOGGING_CATEGORY(logGitHub, "topbar.clients.github", QtInfoMsg)

QVariantMap GHNotification::toVariantMap() const {
    return {
        {          u"id"_s,           id},
        {      u"reason"_s,       reason},
        {u"subjectTitle"_s, subjectTitle},
        { u"subjectType"_s,  subjectType},
        {u"repoFullName"_s, repoFullName},
        {     u"htmlUrl"_s,      htmlUrl},
        {   u"updatedAt"_s,    updatedAt},
        {      u"unread"_s,       unread},
    };
}

GitHub *GitHub::gInstance = nullptr;
GitHub *GitHub::instance() {
    if (!gInstance) { gInstance = new GitHub(); }
    return gInstance;
}

GitHub::GitHub(QObject *parent)
    : QObject(parent), clientId(envOrEmpty("TOPBAR_GH_CLIENT_ID")),
      clientSecret(envOrEmpty("TOPBAR_GH_CLIENT_SECRET")),
      qnam(new QNetworkAccessManager(this)), oauth2(qnam, this),
      settings(QStringLiteral("topbar"), QStringLiteral("github-client")) {
    gInstance = this;

    qCInfo(logGitHub) << "Starting GitHub client";

    setupApi();
    setupOAuth();
    loadPersistedState();

    pollTimer.setTimerType(Qt::VeryCoarseTimer);
    setPollIntervalSeconds(DEFAULTPOLLINTERVALSEC);
    connect(&pollTimer, &QTimer::timeout, this, &GitHub::poll);

    if (!oauth2.token().isEmpty()) {
        applyToken(oauth2.token());
    } else if (this->clientId.isEmpty()) {
        qCWarning(logGitHub) << "No GitHub OAuth client ID configured";
    }
}

GitHub::~GitHub() { persistSeenIds(); }

void GitHub::setupApi() {
    network = new QRestAccessManager(qnam, this);

    api.setBaseUrl(QUrl(APIBASEURL));

    QHttpHeaders headers;
    headers.append(
        QHttpHeaders::WellKnownHeader::Accept, "application/vnd.github+json"
    );

    headers.append(
        QHttpHeaders::WellKnownHeader::UserAgent, "topbar-github-client/1.0"
    );

    headers.append("X-GitHub-Api-Version", "2026-03-10");
    api.setCommonHeaders(headers);
}

void GitHub::setupOAuth() {
    oauth2.setAuthorizationUrl(QUrl(DEVICECODEURL));
    oauth2.setTokenUrl(QUrl(ACCESSTOKENURL));
    oauth2.setClientIdentifier(this->clientId);

    if (!this->clientSecret.isEmpty()) {
        oauth2.setClientIdentifierSharedKey(this->clientSecret.toUtf8());
    }

    oauth2.setRequestedScopeTokens({QByteArrayLiteral("notifications")});
    // gh returns application/x-www-form-urlencoded
    // unless explicitly asked for JSON
    // QOAuth2DeviceAuthorizationFlow expects RFC 8628 JSON
    oauth2.setNetworkRequestModifier(
        this, [](QNetworkRequest &request, QAbstractOAuth::Stage
              ) { request.setRawHeader("Accept", "application/json"); }
    );

    connect(
        &oauth2, &QOAuth2DeviceAuthorizationFlow::authorizeWithUserCode, this,
        [this](
            const QUrl &verificationUrl, const QString &userCode,
            const QUrl &completeVerificationUrl
        ) {
            const QUrl target = completeVerificationUrl.isValid()
                                  ? completeVerificationUrl
                                  : verificationUrl;
            qCInfo(logGitHub) << "GitHub device authorization link:" << target
                              << "code:" << userCode;

            emit deviceAuthorizationRequired(target.toString(), userCode);
            QDesktopServices::openUrl(target);
        }
    );

    connect(&oauth2, &QAbstractOAuth::granted, this, [this]() {
        qCInfo(logGitHub) << "GitHub device authorization granted";
        this->applyToken(oauth2.token());
    });

    connect(
        &oauth2, &QAbstractOAuth::requestFailed,
        [](QAbstractOAuth::Error err) {
            const QString message =
                QStringLiteral("GitHub OAuth request failed (%1)")
                    .arg(int(err));

            qCWarning(logGitHub) << message;
        }
    );

    connect(
        &oauth2, &QAbstractOAuth2::serverReportedErrorOccurred,
        [](const QString &err, const QString &description, const QUrl &) {
            const QString message =
                QStringLiteral("GitHub OAuth error: %1 (%2)")
                    .arg(err, description);

            qCWarning(logGitHub) << message;
        }
    );
}

void GitHub::applyToken(const QString &accessToken) {
    if (accessToken.isEmpty()) {
        this->authenticated = false;
        emit authenticatedChanged();

        return;
    }

    api.setBearerToken(accessToken.toUtf8());
    settings.setValue(QStringLiteral("oauth/token"), accessToken);
    settings.sync();

    this->authenticated = true;
    emit authenticatedChanged();

    poll();
    if (!pollTimer.isActive()) { pollTimer.start(); }
}

void GitHub::login() {
    if (this->clientId.isEmpty()) {
        qCWarning(logGitHub)
            << "Cannot login to GitHub: no OAuth client ID configured";

        return;
    }

    oauth2.grant();
}

void GitHub::logout() {
    pollTimer.stop();
    oauth2.setToken({});
    settings.remove(QStringLiteral("oauth/token"));
    settings.sync();
    this->authenticated = false;
    emit authenticatedChanged();
}

void GitHub::refresh() { poll(); }

void GitHub::setPollIntervalSeconds(int seconds) {
    seconds = qMax(seconds, MINPOLLINTERVALSEC);
    if (pollTimer.interval() / 1000 == seconds) { return; }
    pollTimer.setInterval(seconds * 1000);
    emit pollIntervalSecondsChanged();
}

QVariantList GitHub::notificationsVariant() const {
    QVariantList list;
    list.reserve(current.size());
    for (const auto &n : current) { list.append(n.toVariantMap()); }

    return list;
}

void GitHub::loadPersistedState() {
    const QString token =
        settings.value(QStringLiteral("oauth/token")).toString();

    if (!token.isEmpty()) { oauth2.setToken(token); }

    const QStringList ids =
        settings.value(QStringLiteral("notifications/seenIds")).toStringList();

    seenIds = QSet<QString>(ids.begin(), ids.end());

    lastModified =
        settings.value(QStringLiteral("notifications/lastModified")).toString();

    etag = settings.value(QStringLiteral("notifications/etag")).toString();
}

void GitHub::persistSeenIds() {
    settings.setValue(
        QStringLiteral("notifications/seenIds"),
        QStringList(seenIds.begin(), seenIds.end())
    );

    settings.sync();
}

void GitHub::persistLastPoll() {
    settings.setValue(
        QStringLiteral("notifications/lastModified"), lastModified
    );

    settings.setValue(QStringLiteral("notifications/etag"), etag);
    settings.sync();
}

void GitHub::poll() {
    if (!this->authenticated) { return; }

    QUrlQuery query;
    query.addQueryItem(QStringLiteral("all"), QStringLiteral("false"));
    query.addQueryItem(
        QStringLiteral("participating"), QStringLiteral("false")
    );

    QNetworkRequest request =
        api.createRequest(QString(NOTIFICATIONSPATH), query);

    if (!lastModified.isEmpty()) {
        request.setRawHeader("If-Modified-Since", lastModified.toUtf8());
    }

    if (!etag.isEmpty()) {
        request.setRawHeader("If-None-Match", etag.toUtf8());
    }

    network->get(request, this, [this](QRestReply &reply) {
        handleNotificationsReply(reply);
    });
}

void GitHub::handleNotificationsReply(QRestReply &reply) {
    if (const auto *response = reply.networkReply()) {
        if (const QByteArray pollInterval =
                response->rawHeader("X-Poll-Interval");
            !pollInterval.isEmpty()) {
            setPollIntervalSeconds(pollInterval.toInt());
        }

        if (const QByteArray newLastModified =
                response->rawHeader("Last-Modified");
            !newLastModified.isEmpty()) {
            lastModified = QString::fromUtf8(newLastModified);
        }

        if (const QByteArray newEtag = response->rawHeader("ETag");
            !newEtag.isEmpty()) {
            etag = QString::fromUtf8(newEtag);
        }
    }

    if (reply.httpStatus() == 304) { return; }
    if (!reply.isSuccess()) {
        emit error(QStringLiteral("Failed to fetch GitHub notifications: %1")
                       .arg(reply.errorString()));

        return;
    }

    const auto json = reply.readJson();
    if (!json || !json->isArray()) { return; }

    persistLastPoll();

    current.clear();
    bool anyNew = false;

    for (const QJsonValue &value : json->array()) {
        const QJsonObject obj = value.toObject();

        GHNotification n;
        n.id = obj.value("id").toString();
        n.reason = obj.value("reason").toString();
        n.updatedAt = QDateTime::fromString(
            obj.value("updated_at").toString(), Qt::ISODate
        );

        n.unread = obj.value("unread").toBool(true);

        const QJsonObject subject = obj.value("subject").toObject();
        n.subjectTitle = subject.value("title").toString();
        n.subjectType = subject.value("type").toString();

        const QJsonObject repository = obj.value("repository").toObject();
        n.repoFullName = repository.value("full_name").toString();
        n.htmlUrl = repository.value("html_url").toString();

        current.append(n);

        if (n.unread && !seenIds.contains(n.id)) {
            seenIds.insert(n.id);
            anyNew = true;
            this->spawnNotification(n);
        }
    }

    if (anyNew) { persistSeenIds(); }

    emit notificationsUpdated();
}

void GitHub::spawnNotification(const GHNotification &notification) const {
    const QString title =
        notification.repoFullName.isEmpty()
            ? notification.reason
            : QStringLiteral("%1 · %2").arg(
                  notification.repoFullName, notification.subjectType
              );

    const QString body = notification.subjectTitle;

    const QStringList args = {
        QStringLiteral("--app-name=GitHub"),
        QStringLiteral("--urgency=normal"),
        QStringLiteral("--expire-time=0"),
        QStringLiteral("--hint=string:x-github-thread-id:%1")
            .arg(notification.id),
        title,
        body,
    };

    QProcess::startDetached(QStringLiteral("notify-send"), args);
}

void GitHub::markAsRead(const QString &threadId) {
    if (threadId.isEmpty()) { return; }

    const QString path = QStringLiteral("notifications/threads/") + threadId;
    const QNetworkRequest request = api.createRequest(path);

    QNetworkReply *reply = qnam->sendCustomRequest(request, "PATCH");
    connect(reply, &QNetworkReply::finished, this, [this, reply, threadId]() {
        reply->deleteLater();
        if (reply->error() != QNetworkReply::NoError) {
            emit error(QStringLiteral(
                           "Failed to mark GitHub notification %1 as read: %2"
            )
                           .arg(threadId, reply->errorString()));

            return;
        }

        qCDebug(logGitHub) << "Marked thread" << threadId
                           << "as read on GitHub";
    });
}

void GitHub::markAllAsRead() {
    QNetworkRequest request = api.createRequest(QString(NOTIFICATIONSPATH));
    request.setHeader(
        QNetworkRequest::ContentTypeHeader, QStringLiteral("application/json")
    );

    const QJsonObject body{
        {"last_read_at", QDateTime::currentDateTimeUtc().toString(Qt::ISODate)}
    };

    QNetworkReply *reply =
        qnam->sendCustomRequest(request, "PUT", QJsonDocument(body).toJson());

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        if (reply->error() != QNetworkReply::NoError) {
            emit error(QStringLiteral(
                           "Failed to mark all GitHub notifications as read: %1"
            )
                           .arg(reply->errorString()));

            return;
        }

        current.clear();
        emit notificationsUpdated();
        poll();
    });
}

} // namespace topbar::Clients
