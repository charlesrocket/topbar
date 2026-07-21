#pragma once

#include <QAbstractListModel>
#include <QList>
#include <QQmlListProperty>
#include <functional>
#include <qqmlregistration.h>

class UntypedObjectModel : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(QList<QObject *> values READ values NOTIFY valuesChanged)
    QML_NAMED_ELEMENT(ObjectModel)
    QML_UNCREATABLE("ObjectModels cannot be created directly.")

  public:
    explicit UntypedObjectModel(QObject *parent = nullptr)
        : QAbstractListModel(parent) {}

    [[nodiscard]] [[nodiscard]] [[nodiscard]] QHash<int, QByteArray>
    roleNames() const override {
        return {
            {Qt::UserRole, "modelData"}
        };
    }

    virtual QList<QObject *> values() = 0;
    Q_INVOKABLE virtual qsizetype indexOf(QObject *object) const = 0;

  signals:
    void valuesChanged();
    void objectInsertedPre(QObject *object, qsizetype index);
    void objectInsertedPost(QObject *object, qsizetype index);
    void objectRemovedPre(QObject *object, qsizetype index);
    void objectRemovedPost(QObject *object, qsizetype index);
};

template <typename T> class ObjectModel : public UntypedObjectModel {
  public:
    explicit ObjectModel(QObject *parent = nullptr)
        : UntypedObjectModel(parent) {}

    [[nodiscard]] const QList<T *> &valueList() const { return mValuesList; }
    QList<T *> &valueList() { return mValuesList; }

    void insertObject(T *object, qsizetype index = -1) {
        auto i = (index == -1) ? mValuesList.length() : index;
        emit objectInsertedPre(object, i);
        int const intIndex = static_cast<int>(i);
        beginInsertRows(QModelIndex(), intIndex, intIndex);
        mValuesList.insert(i, object);
        endInsertRows();
        emit valuesChanged();
        emit objectInsertedPost(object, i);
    }

    void insertObjectSorted(
        T *object, const std::function<bool(T *, T *)> &compare
    ) {
        auto &list = mValuesList;
        auto iter = list.begin();
        while (iter != list.end()) {
            if (!compare(object, *iter)) break;
            ++iter;
        }

        insertObject(object, iter - list.begin());
    }

    bool removeObject(const T *object) {
        auto index = mValuesList.indexOf(object);
        if (index == -1) return false;
        removeAt(index);
        return true;
    }

    void removeAt(qsizetype index) {
        auto *object = mValuesList.at(index);
        emit objectRemovedPre(object, index);
        int const intIndex = static_cast<int>(index);
        beginRemoveRows(QModelIndex(), intIndex, intIndex);
        mValuesList.removeAt(index);
        endRemoveRows();
        emit valuesChanged();
        emit objectRemovedPost(object, index);
    }

    void diffUpdate(const QList<T *> &newValues) {
        for (qsizetype i = 0; i < mValuesList.length();) {
            if (newValues.contains(mValuesList.at(i)))
                ++i;
            else
                removeAt(i);
        }

        qsizetype oi = 0;
        for (auto *object : newValues) {
            if (mValuesList.length() == oi || mValuesList.at(oi) != object) {
                auto old = mValuesList.indexOf(object, oi);
                if (old != -1) removeAt(old);
                insertObject(object, oi);
            }

            ++oi;
        }
    }

    static ObjectModel *emptyInstance() {
        static ObjectModel instance;
        return &instance;
    }

    [[nodiscard]] [[nodiscard]] [[nodiscard]] int
    rowCount(const QModelIndex &parent = QModelIndex()) const override {
        if (parent.isValid()) return 0;
        return static_cast<int>(mValuesList.length());
    }

    [[nodiscard]] QVariant
    data(const QModelIndex &index, int role = Qt::UserRole) const override {
        if (!index.isValid() || role != Qt::UserRole) return {};
        return QVariant::fromValue(
            reinterpret_cast<QObject *>(mValuesList.at(index.row()))
        );
    }

    qsizetype indexOf(QObject *object) const override {
        return mValuesList.indexOf(reinterpret_cast<T *>(object));
    }

    QList<QObject *> values() override {
        QList<QObject *> result;
        result.reserve(mValuesList.size());
        for (auto *obj : mValuesList)
            result.append(reinterpret_cast<QObject *>(obj));

        return result;
    }

  private:
    QList<T *> mValuesList;
};
