#include "github.hpp"

#include <QAbstractOAuth2>
#include <QAbstractOAuth>
#include <QDate>
#include <QDesktopServices>
#include <QHttpHeaders>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <QLoggingCategory>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QOAuth2DeviceAuthorizationFlow>
#include <QProcess>
#include <QRestAccessManager>
#include <QRestReply>
#include <QSet>
#include <QStringLiteral>
#include <QTimer>
#include <QUrlQuery>
#include <QVariantMap>
#include <QtMinMax>
#include <qt6keychain/keychain.h>

namespace {
using namespace Qt::StringLiterals;

constexpr auto GITHUB_CLIENT_ID = "Ov23ligQg7RPhr4kPI8Q";
constexpr auto APIBASEURL = "https://api.github.com";
constexpr auto NOTIFICATIONSPATH = "/notifications";
constexpr auto KEYCHAIN_SERVICE = "topbar-github-client";
constexpr int DEFAULTPOLLINTERVALSEC = 90;
constexpr int MINPOLLINTERVALSEC = 60;

QUrl githubDeviceCodeUrl() {
    return QUrl(QStringLiteral("https://github.com/login/device/code"));
}

QUrl githubTokenUrl() {
    return QUrl(QStringLiteral("https://github.com/login/oauth/access_token"));
}

} // namespace

namespace topbar::clients {

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

GitHub::GitHub(QObject *parent)
    : QObject(parent),
      settings(QStringLiteral("topbar"), QStringLiteral("github-client")) {
    qCInfo(logGitHub) << "GitHub client prepared (idling)";

    pollTimer.setTimerType(Qt::VeryCoarseTimer);
    connect(&pollTimer, &QTimer::timeout, this, &GitHub::poll);

    loadNotificationCache();
}

GitHub::~GitHub() { stop(); }

bool GitHub::authenticated() const { return this->mAuthenticated; }
bool GitHub::enabled() const { return this->mEnabled; }

void GitHub::setEnabled(bool value) {
    if (this->enabled() == value) { return; }

    this->mEnabled = value;
    emit enabledChanged();

    this->enabled() ? start() : stop();
}

void GitHub::start() {
    if (qnam) { return; }

    qCInfo(logGitHub) << "Starting GitHub client";

    qnam = new QNetworkAccessManager(this);
    network = new QRestAccessManager(qnam, this);

    setupApi();
    setupOAuth();
    loadOAuthTokens();
}

void GitHub::stop() {
    if (!qnam) { return; }

    qCInfo(logGitHub) << "Stopping GitHub client";
    pollTimer.stop();
    if (oauth2) { oauth2->stopTokenPolling(); }
    persistSeenIds();

    delete network;
    network = nullptr;

    delete oauth2;
    oauth2 = nullptr;

    delete qnam;
    qnam = nullptr;

    api.clearBearerToken();
    this->mAuthenticated = false;
    emit authenticatedChanged();
}

void GitHub::setupApi() {
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
    if (oauth2) { return; }

    qCInfo(logGitHub) << "Configuring device authorization flow";

    oauth2 = new QOAuth2DeviceAuthorizationFlow(qnam, this);
    oauth2->setAuthorizationUrl(githubDeviceCodeUrl());
    oauth2->setTokenUrl(githubTokenUrl());
    oauth2->setClientIdentifier(QString::fromUtf8(GITHUB_CLIENT_ID));
    oauth2->setRequestedScopeTokens({"notifications"});
    oauth2->setNetworkRequestModifier(
        this, [](QNetworkRequest &request, QAbstractOAuth::Stage
              ) { request.setRawHeader("Accept", "application/json"); }
    );

    oauth2->setAutoRefresh(true);

    connect(
        oauth2, &QOAuth2DeviceAuthorizationFlow::authorizeWithUserCode, this,
        [this](
            const QUrl &verificationUrl, const QString &userCode,
            const QUrl &completeVerificationUrl
        ) {
            qCInfo(logGitHub) << "Device authorization link:" << verificationUrl
                              << "code:" << userCode;

            emit deviceAuthorizationRequired(
                verificationUrl.toString(), userCode
            );

            const QUrl openUrl = completeVerificationUrl.isValid()
                                   ? completeVerificationUrl
                                   : verificationUrl;

            QProcess::startDetached(
                "xdg-open", QStringList() << openUrl.toString()
            );

            const QStringList args = {
                QStringLiteral("--app-name=GitHub"),
                QStringLiteral("--urgency=critical"),
                QStringLiteral("--expire-time=20000"),
                QStringLiteral("Authorization code"),
                userCode,
            };

            QProcess::startDetached(QStringLiteral("notify-send"), args);
        }
    );

    connect(
        oauth2, &QAbstractOAuth::statusChanged, this,
        [this](QAbstractOAuth::Status status) {
            switch (status) {
                case QAbstractOAuth::Status::Granted:
                    if (!this->authenticated()) {
                        qCInfo(logGitHub) << "Authorization granted";
                        onOAuthGranted();
                    } else {
                        api.setBearerToken(oauth2->token().toUtf8());
                    }

                    if (!oauth2->refreshToken().isEmpty()) {
                        // refresh failed, fallback to device login
                        login();
                    }
                    break;
                case QAbstractOAuth::Status::NotAuthenticated:
                    onOAuthDeauthenticated();
                    break;
                default: break;
            }
        }
    );

    connect(
        oauth2, &QAbstractOAuth::tokenChanged, this,
        [this](const QString &token) {
            if (token.isEmpty()) { return; }
            auto *job = new QKeychain::WritePasswordJob(
                QLatin1String(KEYCHAIN_SERVICE), this
            );

            job->setAutoDelete(true);
            job->setKey(QStringLiteral("oauth/token"));
            job->setTextData(token);

            connect(
                job, &QKeychain::Job::finished, this,
                [](QKeychain::Job *job) {
                    if (job->error() != QKeychain::NoError) {
                        qCWarning(logGitHub) << "Failed to store access token:"
                                             << job->errorString();
                    }
                }
            );

            job->start();
            api.setBearerToken(token.toUtf8());
        }
    );

    connect(
        oauth2, &QAbstractOAuth2::refreshTokenChanged, this,
        [this](const QString &refreshToken) {
            if (refreshToken.isEmpty()) { return; }
            auto *job = new QKeychain::WritePasswordJob(
                QLatin1String(KEYCHAIN_SERVICE), this
            );

            job->setAutoDelete(true);
            job->setKey(QStringLiteral("oauth/refreshToken"));
            job->setTextData(refreshToken);

            connect(
                job, &QKeychain::Job::finished, this,
                [](QKeychain::Job *job) {
                    if (job->error() != QKeychain::NoError) {
                        qCWarning(logGitHub) << "Failed to store refresh token:"
                                             << job->errorString();
                    }
                }
            );

            job->start();
        }
    );

    connect(
        oauth2, &QAbstractOAuth2::serverReportedErrorOccurred,
        [](const QString &err, const QString &errorDescription, const QUrl &) {
            qCWarning(logGitHub)
                << "OAuth server error:" << err << errorDescription;
        }
    );
}

void GitHub::loadOAuthTokens() {
    if (this->authenticated()) { return; }

    auto *job =
        new QKeychain::ReadPasswordJob(QLatin1String(KEYCHAIN_SERVICE), this);

    job->setAutoDelete(true);
    job->setKey(QStringLiteral("oauth/token"));

    connect(job, &QKeychain::Job::finished, this, [this](QKeychain::Job *job) {
        auto *readJob = qobject_cast<QKeychain::ReadPasswordJob *>(job);
        const QString token = (job->error() == QKeychain::NoError)
                                ? readJob->textData()
                                : QString();

        if (token.isEmpty()) {
            login();
            return;
        }

        qCInfo(logGitHub) << "Setting OAuth refresh token";

        auto *refreshJob = new QKeychain::ReadPasswordJob(
            QLatin1String(KEYCHAIN_SERVICE), this
        );

        refreshJob->setAutoDelete(true);
        refreshJob->setKey(QStringLiteral("oauth/refreshToken"));

        connect(
            refreshJob, &QKeychain::Job::finished, this,
            [this, token](QKeychain::Job *refreshJob) {
                auto *rJob =
                    qobject_cast<QKeychain::ReadPasswordJob *>(refreshJob);

                if (refreshJob->error() == QKeychain::NoError
                    && !rJob->textData().isEmpty()) {
                    oauth2->setRefreshToken(rJob->textData());
                }

                oauth2->setToken(token);
                onOAuthGranted();
            }
        );

        refreshJob->start();
    });

    job->start();
}

void GitHub::login() {
    if (!oauth2) {
        qCWarning(logGitHub) << "Cannot start login (device flow not ready)";
        return;
    }

    qCInfo(logGitHub) << "Initiating device flow";
    oauth2->grant();
}

void GitHub::onOAuthGranted() {
    if (this->authenticated()) { return; }

    api.setBearerToken(oauth2->token().toUtf8());
    this->mAuthenticated = true;
    emit authenticatedChanged();

    const QStringList args = {
        QStringLiteral("--app-name=GitHub"),
        QStringLiteral("--urgency=low"),
        QStringLiteral("Logged in"),
    };

    QProcess::startDetached(QStringLiteral("notify-send"), args);

    setPollIntervalSeconds(DEFAULTPOLLINTERVALSEC);
    poll();

    if (!pollTimer.isActive()) { pollTimer.start(); }
}

void GitHub::onOAuthDeauthenticated() {
    if (this->authenticated()) {
        this->mAuthenticated = false;
        emit authenticatedChanged();
    }

    pollTimer.stop();
}

void GitHub::logout() {
    pollTimer.stop();

    if (oauth2) {
        oauth2->stopTokenPolling();
        oauth2->setToken(QString());
        oauth2->setRefreshToken(QString());
    }

    api.clearBearerToken();

    for (const QString &key :
         {QStringLiteral("oauth/token"), QStringLiteral("oauth/refreshToken")
         }) {
        auto *job = new QKeychain::DeletePasswordJob(
            QLatin1String(KEYCHAIN_SERVICE), this
        );

        job->setAutoDelete(true);
        job->setKey(key);
        job->start();
    }

    this->mAuthenticated = false;
    emit authenticatedChanged();
    qCInfo(logGitHub) << "Logged out";

    const QStringList args = {
        QStringLiteral("--app-name=GitHub"),
        QStringLiteral("--urgency=low"),
        QStringLiteral("Logged out"),
    };

    QProcess::startDetached(QStringLiteral("notify-send"), args);
}

void GitHub::refresh() { poll(); }

int GitHub::pollIntervalSeconds() const { return pollTimer.interval() / 1000; }

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

void GitHub::loadNotificationCache() {
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
    if (!this->authenticated() || !network) { return; }

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
    if (!network) { return; }

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

    if (reply.httpStatus() == 401) {
        qCWarning(logGitHub) << "Access token rejected";
        if (oauth2 && !oauth2->refreshToken().isEmpty()) {
            qCInfo(logGitHub) << "Refreshing the token";
            oauth2->refreshTokens();
        } else {
            qCWarning(logGitHub) << "No refresh token, authorizing";
            logout();
            login();
        }

        return;
    }

    if (!reply.isSuccess()) {
        qCWarning(logGitHub)
            << "Failed to fetch notifications:" << reply.errorString();

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
        QStringLiteral("--hint=string:x-github-thread-id:%1")
            .arg(notification.id),
        title,
        body,
    };

    QProcess::startDetached(QStringLiteral("notify-send"), args);
}

void GitHub::markAsRead(const QString &threadId) {
    if (threadId.isEmpty() || !qnam) { return; }

    const QString path = QStringLiteral("notifications/threads/") + threadId;
    const QNetworkRequest request = api.createRequest(path);

    QNetworkReply *reply = qnam->sendCustomRequest(request, "PATCH");
    connect(reply, &QNetworkReply::finished, [reply, threadId]() {
        reply->deleteLater();
        if (reply->error() != QNetworkReply::NoError) {

            qCWarning(logGitHub)
                << "Failed to mark notifications as read:" << threadId
                << reply->errorString();

            return;
        }

        qCInfo(logGitHub) << "Marked thread" << threadId << "as read on GitHub";
    });
}

} // namespace topbar::clients
