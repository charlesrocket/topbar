#pragma once

#include "space.hpp"

#include <QtGlobal>
#include <qlist.h>
#include <qobject.h>
#include <qqmlengine.h>
#include <qqmlintegration.h>
#include <qqmllist.h>
#include <qstring.h>
#include <qstringlist.h>
#include <qtmetamacros.h>

namespace topbar::nullspace {

class IpcClient;

class NullspaceIpc : public QObject {
    Q_OBJECT;
    QML_ELEMENT;
    QML_SINGLETON;

    // clang-format off
    Q_PROPERTY(bool available READ available NOTIFY availableChanged);
    Q_PROPERTY(quint32 spaceCount READ spaceCount NOTIFY spaceCountChanged);
    Q_PROPERTY(QStringList layouts READ layouts CONSTANT);

    Q_PROPERTY(QString layoutName READ layoutName NOTIFY layoutNameChanged);
    Q_PROPERTY(quint32 layoutIndex READ layoutIndex NOTIFY layoutIndexChanged);
    Q_PROPERTY(quint32 currentSpace READ currentSpace NOTIFY currentSpaceChanged);
    Q_PROPERTY(QString kbLayout READ kbLayout NOTIFY kbLayoutChanged);
    Q_PROPERTY(QString focusedTitle READ focusedTitle NOTIFY focusedTitleChanged);
    Q_PROPERTY(QString focusedAppId READ focusedAppId NOTIFY focusedAppIdChanged);

    Q_PROPERTY(QQmlListProperty<topbar::nullspace::NullspaceSpace> spaces READ spaces NOTIFY spacesChanged);

    Q_PROPERTY(quint32 nmasters READ nmasters NOTIFY nmastersChanged);
    Q_PROPERTY(qreal mfact READ mfact NOTIFY mfactChanged);
    Q_PROPERTY(qint32 gapOuterH READ gapOuterH NOTIFY gapOuterHChanged);
    Q_PROPERTY(qint32 gapOuterV READ gapOuterV NOTIFY gapOuterVChanged);
    Q_PROPERTY(qint32 gapInnerH READ gapInnerH NOTIFY gapInnerHChanged);
    Q_PROPERTY(qint32 gapInnerV READ gapInnerV NOTIFY gapInnerVChanged);
    Q_PROPERTY(bool smartGaps READ smartGaps NOTIFY smartGapsChanged);
    Q_PROPERTY(bool centerOverspread READ centerOverspread NOTIFY centerOverspreadChanged);
    Q_PROPERTY(bool centerWhenSingleStack READ centerWhenSingleStack NOTIFY centerWhenSingleStackChanged);
    // clang-format on

  public:
    static NullspaceIpc *create(QQmlEngine *engine, QJSEngine * /*jsEngine*/) {
        Q_UNUSED(engine)
        return instance();
    }

    static NullspaceIpc *instance();

    [[nodiscard]] bool available() const;
    [[nodiscard]] quint32 spaceCount() const { return this->mSpaceCount; }
    [[nodiscard]] QStringList layouts() const { return this->mLayouts; }

    [[nodiscard]] QString layoutName() const { return this->mLayoutName; }
    [[nodiscard]] quint32 layoutIndex() const { return this->mLayoutIndex; }
    [[nodiscard]] quint32 currentSpace() const { return this->mCurrentSpace; }
    [[nodiscard]] QString kbLayout() const { return this->mKbLayout; }
    [[nodiscard]] QString focusedTitle() const { return this->mFocusedTitle; }
    [[nodiscard]] QString focusedAppId() const { return this->mFocusedAppId; }
    [[nodiscard]] QQmlListProperty<NullspaceSpace> spaces();
    [[nodiscard]] quint32 nmasters() const { return this->mNmasters; }
    [[nodiscard]] qreal mfact() const { return this->mMfact; }
    [[nodiscard]] qint32 gapOuterH() const { return this->mGapOuterH; }
    [[nodiscard]] qint32 gapOuterV() const { return this->mGapOuterV; }
    [[nodiscard]] qint32 gapInnerH() const { return this->mGapInnerH; }
    [[nodiscard]] qint32 gapInnerV() const { return this->mGapInnerV; }
    [[nodiscard]] bool smartGaps() const { return this->mSmartGaps; }
    [[nodiscard]] bool centerOverspread() const {
        return this->mCenterOverspread;
    }
    [[nodiscard]] bool centerWhenSingleStack() const {
        return this->mCenterWhenSingleStack;
    }

    Q_INVOKABLE void switchSpace(int space) const;
    Q_INVOKABLE void moveFocusedToSpace(int space) const;
    Q_INVOKABLE void cycleLayout() const;
    Q_INVOKABLE void setLayoutByIndex(int index) const;
    Q_INVOKABLE void setLayoutByName(const QString &name) const;
    Q_INVOKABLE void setNmasters(int v) const;
    Q_INVOKABLE void setMfact(qreal v) const;
    Q_INVOKABLE void setGapOuterH(int v) const;
    Q_INVOKABLE void setGapOuterV(int v) const;
    Q_INVOKABLE void setGapInnerH(int v) const;
    Q_INVOKABLE void setGapInnerV(int v) const;
    Q_INVOKABLE void setSmartGaps(bool v) const;
    Q_INVOKABLE void setCenterOverspread(bool v) const;
    Q_INVOKABLE void setCenterWhenSingleStack(bool v) const;
    Q_INVOKABLE void closeFocused() const;

  signals:
    void availableChanged();
    void spaceCountChanged();
    void layoutNameChanged();
    void layoutIndexChanged();
    void currentSpaceChanged();
    void kbLayoutChanged();
    void focusedTitleChanged();
    void focusedAppIdChanged();
    void spacesChanged();
    void nmastersChanged();
    void mfactChanged();
    void gapOuterHChanged();
    void gapOuterVChanged();
    void gapInnerHChanged();
    void gapInnerVChanged();
    void smartGapsChanged();
    void centerOverspreadChanged();
    void centerWhenSingleStackChanged();

  private slots:
    void onEventReceived(const QString &key, const QString &value);
    void onConnectedChanged();

  private:
    explicit NullspaceIpc(QObject *parent = nullptr);

    static qsizetype spacesCount(QQmlListProperty<NullspaceSpace> *list);
    static NullspaceSpace *
    spacesAt(QQmlListProperty<NullspaceSpace> *list, qsizetype index);

    void ensureSpaceCount(quint32 n);
    void setActiveSpace(quint32 s);

    IpcClient *mIpc = nullptr;

    quint32 mSpaceCount = 10;
    QStringList mLayouts;

    QString mLayoutName = QStringLiteral("vtile");
    quint32 mLayoutIndex = 0;
    quint32 mCurrentSpace = 0;
    QString mKbLayout;
    QString mFocusedTitle;
    QString mFocusedAppId;
    QList<NullspaceSpace *> mSpaces;

    quint32 mNmasters = 1;
    qreal mMfact = 0.55;
    qint32 mGapOuterH = 0;
    qint32 mGapOuterV = 0;
    qint32 mGapInnerH = 0;
    qint32 mGapInnerV = 0;
    bool mSmartGaps = false;
    bool mCenterOverspread = false;
    bool mCenterWhenSingleStack = true;
};

} // namespace topbar::nullspace
