#pragma once

#include "output.hpp"

#include <QtGlobal>
#include <manager.hpp>
#include <qobject.h>
#include <qqmlintegration.h>
#include <qstring.h>
#include <qstringlist.h>
#include <qtmetamacros.h>

namespace topbar::dwl {

class DwlIpcQml : public QObject {
    Q_OBJECT;
    QML_ELEMENT;
    QML_SINGLETON;
    QML_NAMED_ELEMENT(DwlIpc);

    Q_PROPERTY(quint32 tagCount READ tagCount NOTIFY tagCountChanged);
    Q_PROPERTY(QStringList layouts READ layouts NOTIFY layoutsChanged);
    Q_PROPERTY(QList<topbar::dwl::DwlIpcOutput *> outputs READ outputs NOTIFY
                   outputsChanged);
    Q_PROPERTY(bool available READ available NOTIFY availableChanged);

  public:
    explicit DwlIpcQml(QObject *parent = nullptr);

    // NOLINTBEGIN(misc-include-cleaner)
    [[nodiscard]] quint32 tagCount() const;
    [[nodiscard]] QStringList layouts() const;
    // NOLINTEND(misc-include-cleaner)
    [[nodiscard]] QList<DwlIpcOutput *> outputs() const;
    [[nodiscard]] bool available() const;

    [[nodiscard]] Q_INVOKABLE topbar::dwl::DwlIpcOutput *
    outputForName(const QString &name) const;

  private:
    DwlIpcManager *manager = nullptr;

  signals:
    void tagCountChanged();
    void layoutsChanged();
    void outputsChanged();
    void availableChanged();
};

} // namespace topbar::dwl
