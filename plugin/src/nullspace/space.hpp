#pragma once

#include <QtGlobal>
#include <qobject.h>
#include <qqmlintegration.h>
#include <qtmetamacros.h>

namespace topbar::nullspace {
// NOLINTBEGIN(misc-include-cleaner)
class NullspaceSpace : public QObject {
    Q_OBJECT;
    QML_ELEMENT;
    QML_UNCREATABLE("NullspaceSpace instances are created by NullspaceIpc.");

    // clang-format off
    Q_PROPERTY(quint32 index READ index CONSTANT);
    Q_PROPERTY(bool active READ active NOTIFY activeChanged);
    Q_PROPERTY(quint32 clientCount READ clientCount NOTIFY clientCountChanged);
    // clang-format on

  public:
    explicit NullspaceSpace(quint32 index, QObject *parent = nullptr);

    [[nodiscard]] quint32 index() const { return this->mIndex; }
    [[nodiscard]] bool active() const { return this->mActive; }
    [[nodiscard]] quint32 clientCount() const { return this->mClientCount; }

    void setActive(bool v);
    void setClientCount(quint32 v);

  signals:
    void activeChanged();
    void clientCountChanged();

  private:
    quint32 mIndex;
    bool mActive = false;
    quint32 mClientCount = 0;
};
// NOLINTEND(misc-include-cleaner)
} // namespace topbar::nullspace
