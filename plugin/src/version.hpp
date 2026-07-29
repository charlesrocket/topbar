#pragma once

#include "version.h"

#include <qobject.h>
#include <qqmlintegration.h>
#include <qstring.h>

namespace topbar::version {

using namespace Qt::StringLiterals;

class Version : public QObject {
    Q_OBJECT;
    QML_ELEMENT;
    QML_SINGLETON;

    Q_PROPERTY(int major READ major CONSTANT);
    Q_PROPERTY(int minor READ minor CONSTANT);
    Q_PROPERTY(int patch READ patch CONSTANT);
    Q_PROPERTY(QString full READ full CONSTANT);
    Q_PROPERTY(QString plaform READ platform CONSTANT);
    Q_PROPERTY(QString distributor READ distributor CONSTANT);

  public:
    explicit Version(QObject *parent = nullptr);

    // clang-format off
    [[nodiscard]] static int major() { return PROJECT_VERSION_MAJOR; }
    [[nodiscard]] static int minor() { return PROJECT_VERSION_MINOR; }
    [[nodiscard]] static int patch() { return PROJECT_VERSION_PATCH; }
    [[nodiscard]] static QString full() { return QStringLiteral(PROJECT_VERSION_FULL); }
    [[nodiscard]] static QString platform() { return QStringLiteral(PROJECT_PLATFORM); }
    [[nodiscard]] static QString distributor() { return QStringLiteral(PROJECT_DISTRIBUTOR); }
    // clang-format on
};

} // namespace topbar::version
