#include "output.hpp"

#include "manager.hpp"
#include "tag.hpp"

#include <QtGlobal>
#include <qjsonarray.h>
#include <qjsonobject.h>
#include <qjsonvalue.h>
#include <qlist.h>
#include <qobject.h>
#include <qstring.h>
#include <qtmetamacros.h>
#include <utility>

namespace topbar::mango {

MangoIpcOutput::MangoIpcOutput(
    QString name, MangoIpcManager *manager, QObject *parent
)
    : QObject(parent), mOutputName(std::move(name)), mManager(manager) {}

bool MangoIpcOutput::active() const { return this->mActive; }
quint32 MangoIpcOutput::layoutIndex() const { return this->mLayoutIndex; }
QString MangoIpcOutput::layoutSymbol() const { return this->mLayoutSymbol; }
bool MangoIpcOutput::floating() const { return this->mFloating; }
QList<MangoTag *> MangoIpcOutput::tags() const { return this->mTags; }
QString MangoIpcOutput::kbLayout() const { return this->mKbLayout; }
const QString &MangoIpcOutput::outputName() const { return this->mOutputName; }

void MangoIpcOutput::setTags(quint32 tagmask, quint32 /*toggleTagset*/) {
    if (tagmask == 0) return;

    if ((tagmask & (tagmask - 1)) == 0) {
        quint32 bit = 0;
        quint32 remaining = tagmask;

        while (remaining > 1U) {
            remaining >>= 1U;
            ++bit;
        }

        this->mManager->sendCommand(
            QStringLiteral("dispatch view,%1").arg(bit + 1)
        );

        return;
    }

    for (int i = 0; i < this->mTags.size(); ++i) {
        const bool want = (tagmask & (1U << i)) != 0U;
        const bool have = this->mTags[i]->active();
        if (want != have)
            this->mManager->sendCommand(
                QStringLiteral("dispatch toggleview,%1").arg(i + 1)
            );
    }
}

void MangoIpcOutput::setClientTags(quint32 andTags, quint32 xorTags) {
    if (andTags != 0 && (andTags & (andTags - 1)) == 0) {
        quint32 bit = 0;
        quint32 remaining = andTags;

        while (remaining > 1U) {
            remaining >>= 1U;
            ++bit;
        }

        this->mManager->sendCommand(
            QStringLiteral("dispatch tag,%1").arg(bit + 1)
        );
    }

    for (int i = 0; i < this->mTags.size(); ++i) {
        if ((xorTags & (1U << i)) != 0U)
            this->mManager->sendCommand(
                QStringLiteral("dispatch toggletag,%1").arg(i + 1)
            );
    }
}

void MangoIpcOutput::setLayout(quint32 index) {
    const auto layouts = this->mManager->layouts();
    if (index >= static_cast<quint32>(layouts.size())) return;

    this->mManager->sendCommand(
        QStringLiteral("dispatch setlayout,%1").arg(layouts.at(index))
    );
}

void MangoIpcOutput::initTags(quint32 count) {
    for (MangoTag *t : this->mTags) t->deleteLater();
    this->mTags.clear();
    this->mTags.reserve(static_cast<qsizetype>(count));

    for (quint32 i = 0; i < count; ++i)
        this->mTags.append(new MangoTag(i, this));

    emit this->tagsChanged();
}

void MangoIpcOutput::applyJson(const QJsonObject &json) {
    if (const auto activeVal = json.value("active"); activeVal.isBool()) {
        const bool newActive = activeVal.toBool();
        if (newActive != this->mActive) {
            this->mActive = newActive;
            emit this->activeChanged();
        }
    }

    if (const auto floatingVal = json.value("floating"); floatingVal.isBool()) {
        const bool newFloating = floatingVal.toBool();
        if (newFloating != this->mFloating) {
            this->mFloating = newFloating;
            emit this->floatingChanged();
        }
    }

    if (const auto symbolVal = json.value("layout_symbol");
        symbolVal.isString()) {
        const auto newSymbol = symbolVal.toString();
        if (newSymbol != this->mLayoutSymbol) {
            this->mLayoutSymbol = newSymbol;
            emit this->layoutSymbolChanged();
        }

        if (const auto idxVal = json.value("layout_index"); idxVal.isDouble()) {
            const auto newIndex = static_cast<quint32>(idxVal.toInt());
            if (newIndex != this->mLayoutIndex) {
                this->mLayoutIndex = newIndex;
                emit this->layoutIndexChanged();
            }
        } else if (!newSymbol.isEmpty()) {
            const auto newIndex =
                this->mManager->indexForLayoutSymbol(newSymbol);
            if (newIndex != this->mLayoutIndex) {
                this->mLayoutIndex = newIndex;
                emit this->layoutIndexChanged();
            }
        }
    }

    if (const auto kbVal = json.value("kb_layout"); kbVal.isString()) {
        const auto newKb = kbVal.toString();
        if (newKb != this->mKbLayout) {
            this->mKbLayout = newKb;
            emit this->kbLayoutChanged();
        }
    } else if (const auto kbVal2 = json.value("keyboardlayout");
               kbVal2.isString()) {
        const auto newKb = kbVal2.toString();
        if (newKb != this->mKbLayout) {
            this->mKbLayout = newKb;
            emit this->kbLayoutChanged();
        }
    }

    if (const auto tagsVal = json.value("tags"); tagsVal.isArray()) {
        for (const auto &entry : tagsVal.toArray()) {
            if (!entry.isObject()) continue;
            const auto tagObj = entry.toObject();
            const auto idxVal = tagObj.value("index");
            if (!idxVal.isDouble()) continue;

            const int idx = idxVal.toInt() - 1;
            if (idx < 0 || idx >= this->mTags.size()) continue;

            quint32 state = 0;
            if (const auto stateVal = tagObj.value("state");
                stateVal.isDouble()) {
                state = static_cast<quint32>(stateVal.toInt());
            } else {
                const bool tagActive = tagObj.value("is_active").toBool();
                const bool tagUrgent = tagObj.value("is_urgent").toBool();
                if (tagUrgent)
                    state = 2;
                else if (tagActive)
                    state = 1;
            }

            const auto clients =
                static_cast<quint32>(tagObj.value("client_count").toInt());

            this->mTags[idx]->updateState(state, clients, 0);
        }
    }

    emit this->frame();
}

} // namespace topbar::mango
