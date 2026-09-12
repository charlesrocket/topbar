#pragma once

#include <QtGlobal>
#include <cstdint>
#include <qobject.h>
#include <qqmlintegration.h>
#include <qtmetamacros.h>

namespace topbar::mango {

enum class MangoTagState : uint8_t {
    None = 0,
    Active = 1,
    Urgent = 2,
};

class MangoTag : public QObject {
    Q_OBJECT;
    QML_ELEMENT;
    QML_UNCREATABLE("MangoTag instances are created by MangoIpcOutput.");

    // clang-format off
    Q_PROPERTY(quint32 index READ index CONSTANT);
    Q_PROPERTY(bool active READ active NOTIFY activeChanged);
    Q_PROPERTY(bool urgent READ urgent NOTIFY urgentChanged);
    Q_PROPERTY(quint32 clientCount READ clientCount NOTIFY clientCountChanged);
    Q_PROPERTY(quint32 focusedClient READ focusedClient NOTIFY focusedClientChanged);
    // clang-format on

  public:
    explicit MangoTag(quint32 index, QObject *parent = nullptr);

    [[nodiscard]] quint32 index() const;
    [[nodiscard]] bool active() const;
    [[nodiscard]] bool urgent() const;
    [[nodiscard]] quint32 clientCount() const;
    [[nodiscard]] quint32 focusedClient() const;

    void updateState(quint32 state, quint32 clients, quint32 focused);

  signals:
    void activeChanged();
    void urgentChanged();
    void clientCountChanged();
    void focusedClientChanged();

  private:
    quint32 mIndex;
    bool mActive = false;
    bool mUrgent = false;
    quint32 mClientCount = 0;
    quint32 mFocusedClient = 0;
};

} // namespace topbar::mango
