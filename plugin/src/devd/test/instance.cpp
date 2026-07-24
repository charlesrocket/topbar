#include "../devd.hpp"

#include <qobject.h>
#include <qqmlcomponent.h>
#include <qqmlengine.h>
#include <qscopedpointer.h>
#include <qstring.h>
#include <qtest.h>
#include <qtestcase.h>
#include <qtmetamacros.h>

using namespace topbar::devd;

class TestDevdSingleton : public QObject {
    Q_OBJECT

  private slots:
    static void clones();
};

// all consecutive spawns should point to the first (actual) Devd instance
void TestDevdSingleton::clones() {
    QQmlEngine engine;

    const QByteArray qmlSource = R"(
        import QtQuick
        import TopBar.Devd
        QtObject { property var devdRef: Devd }
    )";

    QQmlComponent component1(&engine);
    component1.setData(qmlSource, QUrl());
    QScopedPointer<QObject> const obj1(component1.create());
    // NOLINTNEXTLINE(misc-include-cleaner)
    QVERIFY2(obj1, qPrintable(component1.errorString()));

    QQmlComponent component2(&engine);
    component2.setData(qmlSource, QUrl());
    QScopedPointer<QObject> const obj2(component2.create());
    // NOLINTNEXTLINE(misc-include-cleaner)
    QVERIFY2(obj2, qPrintable(component2.errorString()));

    QQmlComponent component3(&engine);
    component3.setData(qmlSource, QUrl());
    QScopedPointer<QObject> const obj3(component2.create());
    // NOLINTNEXTLINE(misc-include-cleaner)
    QVERIFY2(obj3, qPrintable(component2.errorString()));

    auto *raw1 = obj1->property("devdRef").value<QObject *>();
    auto *raw2 = obj2->property("devdRef").value<QObject *>();
    auto *raw3 = obj3->property("devdRef").value<QObject *>();

    QVERIFY2(raw1, "devdRef property on obj1 resolved to null QObject*");
    QVERIFY2(raw2, "devdRef property on obj2 resolved to null QObject*");
    QVERIFY2(raw3, "devdRef property on obj3 resolved to null QObject*");

    auto *devd1 = qobject_cast<Devd *>(raw1);
    auto *devd2 = qobject_cast<Devd *>(raw2);
    auto *devd3 = qobject_cast<Devd *>(raw3);

    QVERIFY2(devd1, "obj1's devdRef is not actually a Devd instance");
    QVERIFY2(devd2, "obj2's devdRef is not actually a Devd instance");
    QVERIFY2(devd3, "obj3's devdRef is not actually a Devd instance");

    auto className = QString(devd1->metaObject()->className());

    QCOMPARE(className, QString("topbar::devd::Devd"));

    QCOMPARE(devd1, devd2);
    QCOMPARE(devd2, devd3);

    QCOMPARE(devd1, Devd::instance());
}

QTEST_MAIN(TestDevdSingleton)
#include "instance.moc"
