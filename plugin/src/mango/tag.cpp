#include "tag.hpp"

#include <QtGlobal>
#include <qobject.h>
#include <qtmetamacros.h>

namespace topbar::mango {

// NOLINTBEGIN(misc-include-cleaner)
MangoTag::MangoTag(quint32 index, QObject *parent)
    : QObject(parent), mIndex(index) {}

quint32 MangoTag::index() const { return this->mIndex; }
bool MangoTag::active() const { return this->mActive; }
bool MangoTag::urgent() const { return this->mUrgent; }
quint32 MangoTag::clientCount() const { return this->mClientCount; }
quint32 MangoTag::focusedClient() const { return this->mFocusedClient; }

void MangoTag::updateState(quint32 state, quint32 clients, quint32 focused) {
    const bool newActive = state == static_cast<quint32>(MangoTagState::Active);
    const bool newUrgent = state == static_cast<quint32>(MangoTagState::Urgent);

    if (newActive != this->mActive) {
        this->mActive = newActive;
        emit this->activeChanged();
    }

    if (newUrgent != this->mUrgent) {
        this->mUrgent = newUrgent;
        emit this->urgentChanged();
    }

    if (clients != this->mClientCount) {
        this->mClientCount = clients;
        emit this->clientCountChanged();
    }

    if (focused != this->mFocusedClient) {
        this->mFocusedClient = focused;
        emit this->focusedClientChanged();
    }
}
// NOLINTEND(misc-include-cleaner)

} // namespace topbar::mango
