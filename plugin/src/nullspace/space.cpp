#include "space.hpp"

#include <QtGlobal>
#include <qobject.h>

namespace topbar::nullspace {
// NOLINTBEGIN(misc-include-cleaner)
NullspaceSpace::NullspaceSpace(quint32 index, QObject *parent)
    : QObject(parent), mIndex(index) {}

void NullspaceSpace::setActive(bool v) {
    if (v == this->mActive) return;
    this->mActive = v;
    emit this->activeChanged();
}

void NullspaceSpace::setClientCount(quint32 v) {
    if (v == this->mClientCount) return;
    this->mClientCount = v;
    emit this->clientCountChanged();
}
// NOLINTEND(misc-include-cleaner)
} // namespace topbar::nullspace
