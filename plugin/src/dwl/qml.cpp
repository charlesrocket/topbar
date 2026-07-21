#include "qml.hpp"

#include "manager.hpp"
#include "output.hpp"

#include <QtGlobal>
#include <qlist.h>
#include <qobject.h>
#include <qstring.h>
#include <qstringlist.h>
#include <qwaylandclientextension.h>

namespace topbar::dwl {

DwlIpcQml::DwlIpcQml(QObject *parent)
    : QObject(parent), manager(DwlIpcManager::instance()) {

    QObject::connect(
        this->manager, &DwlIpcManager::tagCountChanged, this,
        &DwlIpcQml::tagCountChanged
    );

    QObject::connect(
        this->manager, &DwlIpcManager::layoutsChanged, this,
        &DwlIpcQml::layoutsChanged
    );

    QObject::connect(
        this->manager, &DwlIpcManager::outputAdded, this,
        &DwlIpcQml::outputsChanged
    );

    QObject::connect(
        this->manager, &DwlIpcManager::outputRemoved, this,
        &DwlIpcQml::outputsChanged
    );

    QObject::connect(
        this->manager, &QWaylandClientExtension::activeChanged, this,
        &DwlIpcQml::availableChanged
    );
}

quint32 DwlIpcQml::tagCount() const { // NOLINT
    return this->manager->tagCount();
}

// NOLINTNEXTLINE(misc-include-cleaner)
QStringList DwlIpcQml::layouts() const { return this->manager->layouts(); }
QList<DwlIpcOutput *> DwlIpcQml::outputs() const {
    return this->manager->outputs();
}
bool DwlIpcQml::available() const { return this->manager->isActive(); }

DwlIpcOutput *DwlIpcQml::outputForName(const QString &name) const {
    for (DwlIpcOutput *o : this->manager->outputs())
        if (o->outputName() == name) return o;

    return nullptr;
}

} // namespace topbar::dwl
