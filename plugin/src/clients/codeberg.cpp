#include "codeberg.hpp"

#include <QHostAddress>
#include <QHttpHeaders>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <QLoggingCategory>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
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

constexpr auto CODEBERG_CLIENT_ID = "8f9c65aa-389c-470f-a3b3-e4111e47b8af";
constexpr auto APIBASEURL = "https://codeberg.org/api/v1";
constexpr auto NOTIFICATIONSPATH = "/notifications";
constexpr auto KEYCHAIN_SERVICE = "topbar-codeberg-client";
constexpr int DEFAULTPOLLINTERVALSEC = 90;
constexpr int MINPOLLINTERVALSEC = 60;

QUrl codebergAuthorizationUrl() {
    return QUrl(QStringLiteral("https://codeberg.org/login/oauth/authorize"));
}

QUrl codebergTokenUrl() {
    return QUrl(QStringLiteral("https://codeberg.org/login/oauth/access_token")
    );
}

} // namespace

namespace topbar::clients {

Q_LOGGING_CATEGORY(logCodeberg, "topbar.clients.codeberg", QtInfoMsg)

QVariantMap CBNotification::toVariantMap() const {
    return {
        {          u"id"_s,           id},
        {u"subjectTitle"_s, subjectTitle},
        { u"subjectType"_s,  subjectType},
        {u"subjectState"_s, subjectState},
        {u"repoFullName"_s, repoFullName},
        {     u"htmlUrl"_s,      htmlUrl},
        {   u"updatedAt"_s,    updatedAt},
        {      u"unread"_s,       unread},
        {      u"pinned"_s,       pinned},
    };
}

Codeberg::Codeberg(QObject *parent)
    : QObject(parent),
      settings(QStringLiteral("topbar"), QStringLiteral("codeberg-client")) {
    qCInfo(logCodeberg) << "Loading Codeberg client";

    pollTimer.setTimerType(Qt::VeryCoarseTimer);
    connect(&pollTimer, &QTimer::timeout, this, &Codeberg::poll);

    loadNotificationCache();
}

Codeberg::~Codeberg() { stop(); }

bool Codeberg::authenticated() const { return this->mAuthenticated; }
bool Codeberg::enabled() const { return this->mEnabled; }

void Codeberg::setEnabled(bool value) {
    if (this->enabled() == value) { return; }

    this->mEnabled = value;
    emit enabledChanged();

    this->enabled() ? start() : stop();
}

void Codeberg::start() {
    if (qnam) { return; }

    qCInfo(logCodeberg) << "Starting Codeberg client";

    qnam = new QNetworkAccessManager(this);
    network = new QRestAccessManager(qnam, this);

    setupApi();
    setupOAuth();
    loadOAuthTokens();
}

void Codeberg::stop() {
    if (!qnam) { return; }

    qCInfo(logCodeberg) << "Stopping Codeberg client";
    pollTimer.stop();
    persistSeenIds();

    delete network;
    network = nullptr;

    delete oauth2;
    oauth2 = nullptr;

    replyHandler = nullptr;

    delete qnam;
    qnam = nullptr;

    api.clearBearerToken();
    this->mAuthenticated = false;
    emit authenticatedChanged();
}

void Codeberg::setupApi() {
    api.setBaseUrl(QUrl(APIBASEURL));

    QHttpHeaders headers;
    headers.append(QHttpHeaders::WellKnownHeader::Accept, "application/json");
    headers.append(
        QHttpHeaders::WellKnownHeader::UserAgent, "topbar-codeberg-client/1.0"
    );

    api.setCommonHeaders(headers);
}

void Codeberg::setupOAuth() {
    if (oauth2) { return; }

    qCInfo(logCodeberg) << "Configuring authorization code + PKCE flow";

    oauth2 = new QOAuth2AuthorizationCodeFlow(qnam, this);
    oauth2->setAuthorizationUrl(codebergAuthorizationUrl());
    oauth2->setTokenUrl(codebergTokenUrl());
    oauth2->setClientIdentifier(QString::fromUtf8(CODEBERG_CLIENT_ID));
    oauth2->setPkceMethod(QOAuth2AuthorizationCodeFlow::PkceMethod::S256);
    oauth2->setAutoRefresh(true);

    // Forgejo's documentation states that
    // auth scopes are NOT implemented!
    oauth2->setRequestedScopeTokens({"read:notification"}); // for posterity

    replyHandler =
        new QOAuthHttpServerReplyHandler(QHostAddress::LocalHost, 0, oauth2);
    oauth2->setReplyHandler(replyHandler);

    connect(
        oauth2, &QOAuth2AuthorizationCodeFlow::authorizeWithBrowser, this,
        [this](const QUrl &url) {
            qCInfo(logCodeberg)
                << "Opening the browser for authorization:" << url;

            emit authorizationRequired(url.toString());

            QProcess::startDetached(
                "xdg-open", QStringList() << url.toString()
            );

            const QStringList args = {
                QStringLiteral("--app-name=Codeberg"),
                QStringLiteral("--urgency=critical"),
                QStringLiteral("--expire-time=20000"),
                QStringLiteral("Authorize in the browser"),
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
                        qCInfo(logCodeberg) << "Authorization granted";
                        onOAuthGranted();
                    } else {
                        api.setBearerToken(oauth2->token().toUtf8());
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
                        qCWarning(logCodeberg)
                            << "Failed to store access token:"
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
                        qCWarning(logCodeberg)
                            << "Failed to store refresh token:"
                            << job->errorString();
                    }
                }
            );

            job->start();
        }
    );

    connect(
        oauth2, &QAbstractOAuth2::serverReportedErrorOccurred,
        [this](const QString &err, const QString &errorDescription, const QUrl &) {
            qCWarning(logCodeberg)
                << "OAuth server error:" << err << errorDescription;
            emit error(errorDescription.isEmpty() ? err : errorDescription);
        }
    );
}

void Codeberg::loadOAuthTokens() {
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

        qCInfo(logCodeberg) << "Setting OAuth refresh token";

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

void Codeberg::login() {
    if (!oauth2) {
        qCWarning(logCodeberg) << "Cannot start login (OAuth flow not ready)";
        return;
    }

    qCInfo(logCodeberg) << "Initiating authorization code + PKCE flow";
    oauth2->grant();
}

void Codeberg::onOAuthGranted() {
    if (this->authenticated()) { return; }

    api.setBearerToken(oauth2->token().toUtf8());
    this->mAuthenticated = true;
    emit authenticatedChanged();

    const QStringList args = {
        QStringLiteral("--app-name=Codeberg"),
        QStringLiteral("--urgency=low"),
        QStringLiteral("Logged in"),
    };

    QProcess::startDetached(QStringLiteral("notify-send"), args);

    setPollIntervalSeconds(DEFAULTPOLLINTERVALSEC);
    poll();

    if (!pollTimer.isActive()) { pollTimer.start(); }
}

void Codeberg::onOAuthDeauthenticated() {
    if (this->authenticated()) {
        this->mAuthenticated = false;
        emit authenticatedChanged();
    }

    pollTimer.stop();
}

void Codeberg::logout() {
    pollTimer.stop();

    if (oauth2) {
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
    qCInfo(logCodeberg) << "Logged out";

    const QStringList args = {
        QStringLiteral("--app-name=Codeberg"),
        QStringLiteral("--urgency=low"),
        QStringLiteral("Logged out"),
    };

    QProcess::startDetached(QStringLiteral("notify-send"), args);
}

void Codeberg::refresh() { poll(); }

int Codeberg::pollIntervalSeconds() const {
    return pollTimer.interval() / 1000;
}

void Codeberg::setPollIntervalSeconds(int seconds) {
    seconds = qMax(seconds, MINPOLLINTERVALSEC);
    if (pollTimer.interval() / 1000 == seconds) { return; }
    pollTimer.setInterval(seconds * 1000);
    emit pollIntervalSecondsChanged();
}

QVariantList Codeberg::notificationsVariant() const {
    QVariantList list;
    list.reserve(current.size());
    for (const auto &n : current) { list.append(n.toVariantMap()); }
    return list;
}

void Codeberg::loadNotificationCache() {
    const QStringList ids =
        settings.value(QStringLiteral("notifications/seenIds")).toStringList();
    seenIds = QSet<QString>(ids.begin(), ids.end());
}

void Codeberg::persistSeenIds() {
    settings.setValue(
        QStringLiteral("notifications/seenIds"),
        QStringList(seenIds.begin(), seenIds.end())
    );
    settings.sync();
}

void Codeberg::poll() {
    if (!this->authenticated() || !network) { return; }

    QUrlQuery query;
    query.addQueryItem(
        QStringLiteral("status-types"), QStringLiteral("unread")
    );

    const QNetworkRequest request =
        api.createRequest(QString(NOTIFICATIONSPATH), query);

    network->get(request, this, [this](QRestReply &reply) {
        handleNotificationsReply(reply);
    });
}

void Codeberg::handleNotificationsReply(QRestReply &reply) {
    if (!network) { return; }

    if (reply.httpStatus() == 401) {
        qCWarning(logCodeberg) << "Access token rejected";
        if (oauth2 && !oauth2->refreshToken().isEmpty()) {
            qCInfo(logCodeberg) << "Refreshing the token";
            oauth2->refreshTokens();
        } else {
            qCWarning(logCodeberg) << "No refresh token, re-authorizing";
            onOAuthDeauthenticated();
            login();
        }

        return;
    }

    if (!reply.isSuccess()) {
        qCWarning(logCodeberg)
            << "Failed to fetch notifications:" << reply.errorString();

        return;
    }

    const auto json = reply.readJson();
    if (!json || !json->isArray()) { return; }

    current.clear();
    bool anyNew = false;

    for (const QJsonValue &value : json->array()) {
        const QJsonObject obj = value.toObject();

        CBNotification n;
        n.id = QString::number(obj.value("id").toInteger());
        n.updatedAt = QDateTime::fromString(
            obj.value("updated_at").toString(), Qt::ISODate
        );

        n.unread = obj.value("unread").toBool(true);
        n.pinned = obj.value("pinned").toBool(false);

        const QJsonObject subject = obj.value("subject").toObject();
        n.subjectTitle = subject.value("title").toString();
        n.subjectType = subject.value("type").toString();
        n.subjectState = subject.value("state").toString();

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

void Codeberg::spawnNotification(const CBNotification &notification) const {
    const QString title =
        notification.repoFullName.isEmpty()
            ? notification.subjectType
            : QStringLiteral("%1 · %2").arg(
                  notification.repoFullName, notification.subjectType
              );

    const QString body = notification.subjectTitle;

    const QStringList args = {
        QStringLiteral("--app-name=Codeberg"),
        QStringLiteral("--urgency=normal"),
        QStringLiteral("--hint=string:x-codeberg-thread-id:%1")
            .arg(notification.id),
        title,
        body,
    };

    QProcess::startDetached(QStringLiteral("notify-send"), args);
}

void Codeberg::markAsRead(const QString &threadId) {
    if (threadId.isEmpty() || !qnam) { return; }

    const QString path = QStringLiteral("notifications/threads/") + threadId;
    const QNetworkRequest request = api.createRequest(path);

    QNetworkReply *reply = qnam->sendCustomRequest(request, "PATCH");
    connect(reply, &QNetworkReply::finished, [reply, threadId]() {
        reply->deleteLater();
        if (reply->error() != QNetworkReply::NoError) {
            qCWarning(logCodeberg)
                << "Failed to mark notification as read:" << threadId
                << reply->errorString();

            return;
        }

        qCInfo(logCodeberg) << "Marked thread" << threadId << "as read";
    });
}

} // namespace topbar::clients
