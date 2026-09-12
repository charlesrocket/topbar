#pragma once

#include "tag.hpp"

#include <QtGlobal>
#include <qjsonobject.h>
#include <qlist.h>
#include <qobject.h>
#include <qqmlintegration.h>
#include <qstring.h>
#include <qtmetamacros.h>

namespace topbar::mango {

class MangoIpcManager;

class MangoIpcOutput : public QObject {
    Q_OBJECT;
    QML_ELEMENT;
    QML_UNCREATABLE("MangoIpcOutput instances are created by MangoIpc.");

    // clang-format off
    Q_PROPERTY(bool active READ active NOTIFY activeChanged);
    Q_PROPERTY(quint32 layoutIndex READ layoutIndex NOTIFY layoutIndexChanged);
    Q_PROPERTY(QString layoutSymbol READ layoutSymbol NOTIFY layoutSymbolChanged);
    Q_PROPERTY(bool floating READ floating NOTIFY floatingChanged);
    Q_PROPERTY(QList<topbar::mango::MangoTag *> tags READ tags NOTIFY tagsChanged);
    Q_PROPERTY(QString kbLayout READ kbLayout NOTIFY kbLayoutChanged);
    // clang-format on

  public:
    explicit MangoIpcOutput(
        QString name, MangoIpcManager *manager, QObject *parent = nullptr
    );

    ~MangoIpcOutput() override = default;

    MangoIpcOutput(const MangoIpcOutput &) = delete;
    MangoIpcOutput &operator=(const MangoIpcOutput &) = delete;
    MangoIpcOutput(MangoIpcOutput &&) = delete;
    MangoIpcOutput &operator=(MangoIpcOutput &&) = delete;

    [[nodiscard]] bool active() const;
    [[nodiscard]] quint32 layoutIndex() const;
    [[nodiscard]] QString layoutSymbol() const;
    [[nodiscard]] bool floating() const;
    [[nodiscard]] QString kbLayout() const;
    [[nodiscard]] QList<MangoTag *> tags() const;
    [[nodiscard]] const QString &outputName() const;

    Q_INVOKABLE void setTags(quint32 tagmask, quint32 toggleTagset = 0);
    Q_INVOKABLE void setClientTags(quint32 andTags, quint32 xorTags);
    Q_INVOKABLE void setLayout(quint32 index);

    void initTags(quint32 count);
    void applyJson(const QJsonObject &json);

  signals:
    void activeChanged();
    void layoutIndexChanged();
    void layoutSymbolChanged();
    void fullscreenChanged();
    void floatingChanged();
    void toggleVisibility();
    void kbLayoutChanged();
    void tagsChanged();

    void frame();

  private:
    QString mOutputName;
    MangoIpcManager *mManager = nullptr;

    bool mActive = false;
    QList<MangoTag *> mTags;
    quint32 mLayoutIndex = 0;
    QString mLayoutSymbol;
    QString mKbLayout;
    bool mFloating = false;
};

} // namespace topbar::mango
