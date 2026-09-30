#include "qml.hpp"

#include "ipc.hpp"
#include "space.hpp"

#include <QChar>
#include <QString>
#include <QStringList>
#include <QtAlgorithms>
#include <QtGlobal>
#include <qlogging.h>
#include <qqmllist.h>

namespace topbar::nullspace {

namespace {
// NOLINTBEGIN(misc-include-cleaner)
const QStringList LAYOUT_NAMES = {
    QStringLiteral("vtile"),   QStringLiteral("vgrid"),
    QStringLiteral("htile"),   QStringLiteral("hrtile"),
    QStringLiteral("monocle"), QStringLiteral("hgrid"),
    QStringLiteral("float"),
};

} // namespace

NullspaceIpc *NullspaceIpc::instance() {
    static auto *inst = new NullspaceIpc();
    return inst;
}

NullspaceIpc::NullspaceIpc(QObject *parent)
    : QObject(parent), mIpc(new IpcClient(this)), mLayouts(LAYOUT_NAMES) {

    QObject::connect(
        this->mIpc, &IpcClient::eventReceived, this,
        &NullspaceIpc::onEventReceived
    );

    QObject::connect(
        this->mIpc, &IpcClient::connectedChanged, this,
        &NullspaceIpc::onConnectedChanged
    );

    this->ensureSpaceCount(this->mSpaceCount);
    this->mSpaces.at(0)->setActive(true);
}

bool NullspaceIpc::available() const { return this->mIpc->isConnected(); }

QQmlListProperty<NullspaceSpace> NullspaceIpc::spaces() {
    return QQmlListProperty<NullspaceSpace>(
        this, nullptr, &NullspaceIpc::spacesCount, &NullspaceIpc::spacesAt
    );
}

qsizetype NullspaceIpc::spacesCount(QQmlListProperty<NullspaceSpace> *list) {
    auto *self = dynamic_cast<NullspaceIpc *>(list->object);
    return self->mSpaces.size();
}

NullspaceSpace *NullspaceIpc::spacesAt(
    QQmlListProperty<NullspaceSpace> *list, qsizetype index
) {
    auto *self = dynamic_cast<NullspaceIpc *>(list->object);
    if (index < 0 || index >= self->mSpaces.size()) return nullptr;
    return self->mSpaces.at(index);
}

void NullspaceIpc::onConnectedChanged() { emit this->availableChanged(); }

void NullspaceIpc::onEventReceived(const QString &key, const QString &value) {
    if (key == QStringLiteral("layout")) {
        if (value == this->mLayoutName) return;
        this->mLayoutName = value;

        const auto idx = this->mLayouts.indexOf(value);
        if (idx >= 0) this->mLayoutIndex = static_cast<quint32>(idx);

        emit this->layoutNameChanged();
        emit this->layoutIndexChanged();
        return;
    }

    if (key == QStringLiteral("current_space")) {
        bool ok = false;
        const auto v = value.toUInt(&ok);
        if (ok) this->setActiveSpace(v);
        return;
    }

    if (key == QStringLiteral("space_count")) {
        bool ok = false;
        const auto v = value.toUInt(&ok);
        if (ok) this->ensureSpaceCount(v);
        return;
    }

    if (key == QStringLiteral("space_window_count")) {
        const auto idx = value.indexOf(QLatin1Char(' '));
        if (idx < 0) return;

        bool okS = false;
        bool okC = false;
        const auto space = value.left(idx).toUInt(&okS);
        const auto count = value.mid(idx + 1).toUInt(&okC);
        if (!okS || !okC) return;
        if (space >= static_cast<quint32>(this->mSpaces.size())) return;

        this->mSpaces[static_cast<qsizetype>(space)]->setClientCount(count);
        return;
    }

    if (key == QStringLiteral("focused_title")) {
        if (value == this->mFocusedTitle) return;
        this->mFocusedTitle = value;
        emit this->focusedTitleChanged();
        return;
    }

    if (key == QStringLiteral("focused_app_id")) {
        if (value == this->mFocusedAppId) return;
        this->mFocusedAppId = value;
        emit this->focusedAppIdChanged();
        return;
    }

    if (key == QStringLiteral("kb_layout")) {
        if (value == this->mKbLayout) return;
        this->mKbLayout = value;
        emit this->kbLayoutChanged();
        return;
    }

    if (key == QStringLiteral("nmasters")) {
        bool ok = false;
        const auto v = value.toUInt(&ok);
        if (!ok || v == this->mNmasters) return;

        this->mNmasters = v;
        emit this->nmastersChanged();
        return;
    }

    if (key == QStringLiteral("mfact")) {
        bool ok = false;
        const auto v = value.toDouble(&ok);
        if (!ok || qFuzzyCompare(v, this->mMfact)) return;

        this->mMfact = v;
        emit this->mfactChanged();
        return;
    }

    auto updateInt = [&](qint32 *slot, void (NullspaceIpc::*signal)()) {
        bool ok = false;
        const auto v = value.toInt(&ok);
        if (!ok || v == *slot) return;

        *slot = v;
        emit(this->*signal)();
    };

    if (key == QStringLiteral("gap_outer_h")) {
        updateInt(&this->mGapOuterH, &NullspaceIpc::gapOuterHChanged);
        return;
    }

    if (key == QStringLiteral("gap_outer_v")) {
        updateInt(&this->mGapOuterV, &NullspaceIpc::gapOuterVChanged);
        return;
    }

    if (key == QStringLiteral("gap_inner_h")) {
        updateInt(&this->mGapInnerH, &NullspaceIpc::gapInnerHChanged);
        return;
    }

    if (key == QStringLiteral("gap_inner_v")) {
        updateInt(&this->mGapInnerV, &NullspaceIpc::gapInnerVChanged);
        return;
    }

    auto updateBool = [&](bool *slot, void (NullspaceIpc::*signal)()) {
        const bool v =
            (value == QStringLiteral("true") || value == QStringLiteral("1"));

        if (v == *slot) return;
        *slot = v;
        emit(this->*signal)();
    };

    if (key == QStringLiteral("smart_gaps")) {
        updateBool(&this->mSmartGaps, &NullspaceIpc::smartGapsChanged);
        return;
    }

    if (key == QStringLiteral("center_overspread")) {
        updateBool(
            &this->mCenterOverspread, &NullspaceIpc::centerOverspreadChanged
        );

        return;
    }

    if (key == QStringLiteral("center_when_single_stack")) {
        updateBool(
            &this->mCenterWhenSingleStack,
            &NullspaceIpc::centerWhenSingleStackChanged
        );

        return;
    }

    // window_opened, window_closed, window, focused, ready — ignored
}

void NullspaceIpc::ensureSpaceCount(quint32 n) {
    if (n == 0) return;
    if (!this->mSpaces.isEmpty()
        && this->mSpaces.size() == static_cast<qsizetype>(n)) {
        return;
    }

    qDeleteAll(this->mSpaces);
    this->mSpaces.clear();
    this->mSpaces.reserve(static_cast<qsizetype>(n));

    for (quint32 i = 0; i < n; ++i)
        this->mSpaces.append(new NullspaceSpace(i, this));

    this->mSpaceCount = n;
    emit this->spaceCountChanged();
    emit this->spacesChanged();
}

void NullspaceIpc::setActiveSpace(quint32 s) {
    if (s == this->mCurrentSpace) return;
    this->mCurrentSpace = s;

    for (auto *space : this->mSpaces) space->setActive(space->index() == s);

    emit this->currentSpaceChanged();
}

void NullspaceIpc::switchSpace(int space) const {
    this->mIpc->send(QStringLiteral("SWITCH_SPACE %1").arg(space));
}

void NullspaceIpc::moveFocusedToSpace(int space) const {
    this->mIpc->send(QStringLiteral("MOVE_TO_SPACE %1").arg(space));
}

void NullspaceIpc::cycleLayout() const {
    this->mIpc->send(QStringLiteral("CYCLE_LAYOUT"));
}

void NullspaceIpc::setLayoutByIndex(int index) const {
    if (index < 0 || index >= this->mLayouts.size()) return;
    this->mIpc->send(
        QStringLiteral("SET layout %1").arg(this->mLayouts.at(index))
    );
}

void NullspaceIpc::setLayoutByName(const QString &name) const {
    if (!this->mLayouts.contains(name)) return;
    this->mIpc->send(QStringLiteral("SET layout %1").arg(name));
}

void NullspaceIpc::setNmasters(int v) const {
    this->mIpc->send(QStringLiteral("SET nmasters %1").arg(v));
}

void NullspaceIpc::setMfact(qreal v) const {
    this->mIpc->send(QStringLiteral("SET mfact %1").arg(v));
}

void NullspaceIpc::setGapOuterH(int v) const {
    this->mIpc->send(QStringLiteral("SET gap_outer_h %1").arg(v));
}

void NullspaceIpc::setGapOuterV(int v) const {
    this->mIpc->send(QStringLiteral("SET gap_outer_v %1").arg(v));
}

void NullspaceIpc::setGapInnerH(int v) const {
    this->mIpc->send(QStringLiteral("SET gap_inner_h %1").arg(v));
}

void NullspaceIpc::setGapInnerV(int v) const {
    this->mIpc->send(QStringLiteral("SET gap_inner_v %1").arg(v));
}

void NullspaceIpc::setSmartGaps(bool v) const {
    this->mIpc->send(
        QStringLiteral("SET smart_gaps %1").arg(v ? "true" : "false")
    );
}

void NullspaceIpc::setCenterOverspread(bool v) const {
    this->mIpc->send(
        QStringLiteral("SET center_overspread %1").arg(v ? "true" : "false")
    );
}

void NullspaceIpc::setCenterWhenSingleStack(bool v) const {
    this->mIpc->send(QStringLiteral("SET center_when_single_stack %1")
                         .arg(v ? "true" : "false"));
}

void NullspaceIpc::closeFocused() const {
    this->mIpc->send(QStringLiteral("CLOSE"));
}
// NOLINTEND(misc-include-cleaner)
} // namespace topbar::nullspace
