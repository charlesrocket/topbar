#pragma once

#include "output.hpp"

#include <QtGlobal>
#include <manager.hpp>
#include <qobject.h>
#include <qqmlintegration.h>
#include <qstring.h>
#include <qstringlist.h>
#include <qtmetamacros.h>

namespace topbar::mango {

class MangoIpcQml : public QObject {
    Q_OBJECT;
    QML_ELEMENT;
    QML_SINGLETON;
    QML_NAMED_ELEMENT(MangoIpc);

    // clang-format off
    Q_PROPERTY(quint32 tagCount READ tagCount NOTIFY tagCountChanged);
    Q_PROPERTY(QStringList layouts READ layouts NOTIFY layoutsChanged);
    Q_PROPERTY(QList<topbar::mango::MangoIpcOutput *> outputs READ outputs NOTIFY outputsChanged);
    Q_PROPERTY(bool available READ available NOTIFY availableChanged);
    // clang-format on

  public:
    explicit MangoIpcQml(QObject *parent = nullptr);

    // NOLINTBEGIN(misc-include-cleaner)
    [[nodiscard]] quint32 tagCount() const;
    [[nodiscard]] QStringList layouts() const;
    // NOLINTEND(misc-include-cleaner)
    [[nodiscard]] QList<MangoIpcOutput *> outputs() const;
    [[nodiscard]] bool available() const;

    [[nodiscard]] Q_INVOKABLE topbar::mango::MangoIpcOutput *
    outputForName(const QString &name) const;

  private:
    MangoIpcManager *manager = nullptr;

  signals:
    void tagCountChanged();
    void layoutsChanged();
    void outputsChanged();
    void availableChanged();
};

} // namespace topbar::mango
