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
    Q_PROPERTY(QString distributor READ distributor CONSTANT);

  public:
    explicit Version(QObject *parent = nullptr);

    // clang-format off
    [[nodiscard]] int major() const { return PROJECT_VERSION_MAJOR; }
    [[nodiscard]] int minor() const { return PROJECT_VERSION_MINOR; }
    [[nodiscard]] int patch() const { return PROJECT_VERSION_PATCH; }
    [[nodiscard]] QString full() const { return u"PROJECT_VERSION_FULL"_s; }
    [[nodiscard]] QString distributor() const { return u"PROJECT_DISTRIBUTOR"_s; }
    // clang-format on
};

} // namespace topbar::version
