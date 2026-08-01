#include "version.hpp"

#include "version.h"

#include <qlogging.h>
#include <qloggingcategory.h>
#include <qobject.h>

namespace topbar::version {

Q_LOGGING_CATEGORY(logVersion, "topbar.version", QtInfoMsg)

Version::Version(QObject *parent) : QObject(parent) {
    qCInfo(logVersion) << PROJECT_VERSION_FULL;
    qCDebug(logVersion) << "distributor" << PROJECT_DISTRIBUTOR;
}

} // namespace topbar::version
