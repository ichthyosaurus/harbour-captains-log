/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef SELECTABLE_SFPM_H
#define SELECTABLE_SFPM_H

#include <QMap>
#include <QVariantList>
#include "../libs/SortFilterProxyModel/qqmlsortfilterproxymodel.h"
#include "../libs/SortFilterProxyModel/proxyroles/singlerole.h"
#include "property_macros.h"

namespace qqsfpm {

class SelectableSortFilterProxyModel;
class IsSelectedRole : public SingleRole {
    Q_OBJECT

public:
    IsSelectedRole(SelectableSortFilterProxyModel* selectionModel,
                   QObject* parent = 0);

private:
    SelectableSortFilterProxyModel* m_selectionModel {nullptr};

    virtual QVariant data(const QModelIndex &sourceIndex,
                          const QQmlSortFilterProxyModel &proxyModel) override;
};


class SelectableSortFilterProxyModel : public QQmlSortFilterProxyModel {
    Q_OBJECT
    RW_PROPERTY(QString, selectionKey, SelectionKey, )
    RO_PROPERTY(QVariantList, selectedKeys, )
    RO_PROPERTY(int, selectedCount, 0)
    RO_PROPERTY(int, filteredSelectedCount, )

public:
    SelectableSortFilterProxyModel(QObject* parent = 0);

    bool isSourceIndexSelected(const QModelIndex& sourceIndex) const;
    int getKeyRole() const;

signals:
    void itemSelected(const QVariant& key);
    void itemDeselected(const QVariant& key);

public slots:
    void selectItem(const QModelIndex& index);
    Q_INVOKABLE void selectItem(int row);

    void deselectItem(const QModelIndex& index);
    Q_INVOKABLE void deselectItem(int row);

    void toggleSelection(const QModelIndex& index);
    Q_INVOKABLE void toggleSelection(int row);

    void selectAll();
    void clearCurrent();
    void clearAll();

    void updateFilteredSelectedCount();

private:
    QMap<QVariant, bool> m_selectedMap;
    QSharedPointer<IsSelectedRole> m_isSelectedRole {new IsSelectedRole(this)};
};

}

#endif // SELECTABLE_SFPM_H
