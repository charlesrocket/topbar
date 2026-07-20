#pragma once

#include "version.h"

#include <qobject.h>
#include <qqmlintegration.h>
#include <qstring.h>

namespace topbar::version {

class Version : public QObject {
    Q_OBJECT;
    QML_ELEMENT;
    QML_SINGLETON;

    Q_PROPERTY(int major READ major CONSTANT);
    Q_PROPERTY(int minor READ minor CONSTANT);
    Q_PROPERTY(int patch READ patch CONSTANT);
    Q_PROPERTY(QString full READ full CONSTANT);
    Q_PROPERTY(QString distributor READ distributor CONSTANT);

  public:
    explicit Version(QObject *parent = nullptr);

    int major() const { return PROJECT_VERSION_MAJOR; }
    int minor() const { return PROJECT_VERSION_MINOR; }
    int patch() const { return PROJECT_VERSION_PATCH; }
    QString full() const { return QStringLiteral(PROJECT_VERSION_FULL); }
    QString distributor() const { return QStringLiteral(PROJECT_DISTRIBUTOR); }
};

} // namespace topbar::version
