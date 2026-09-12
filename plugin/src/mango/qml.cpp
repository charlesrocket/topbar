#include "qml.hpp"

#include "manager.hpp"
#include "output.hpp"

#include <QtGlobal>
#include <qlist.h>
#include <qobject.h>
#include <qstring.h>
#include <qstringlist.h>

namespace topbar::mango {

MangoIpcQml::MangoIpcQml(QObject *parent)
    : QObject(parent), manager(MangoIpcManager::instance()) {

    QObject::connect(
        this->manager, &MangoIpcManager::tagCountChanged, this,
        &MangoIpcQml::tagCountChanged
    );

    QObject::connect(
        this->manager, &MangoIpcManager::layoutsChanged, this,
        &MangoIpcQml::layoutsChanged
    );

    QObject::connect(
        this->manager, &MangoIpcManager::outputAdded, this,
        &MangoIpcQml::outputsChanged
    );

    QObject::connect(
        this->manager, &MangoIpcManager::outputRemoved, this,
        &MangoIpcQml::outputsChanged
    );

    QObject::connect(
        this->manager, &MangoIpcManager::activeChanged, this,
        &MangoIpcQml::availableChanged
    );
}

quint32 MangoIpcQml::tagCount() const { // NOLINT
    return this->manager->tagCount();
}

// NOLINTNEXTLINE(misc-include-cleaner)
QStringList MangoIpcQml::layouts() const { return this->manager->layouts(); }
QList<MangoIpcOutput *> MangoIpcQml::outputs() const {
    return this->manager->outputs();
}

bool MangoIpcQml::available() const { return this->manager->isActive(); }

MangoIpcOutput *MangoIpcQml::outputForName(const QString &name) const {
    for (MangoIpcOutput *o : this->manager->outputs())
        if (o->outputName() == name) return o;

    return nullptr;
}

} // namespace topbar::mango
