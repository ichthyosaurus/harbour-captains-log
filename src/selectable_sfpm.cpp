/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "selectable_sfpm.h"

namespace qqsfpm {

IsSelectedRole::IsSelectedRole(SelectableSortFilterProxyModel* selectionModel,
                               QObject* parent) :
    SingleRole(parent), m_selectionModel(selectionModel)
{
    setName(QStringLiteral("isSelected"));
}

QVariant IsSelectedRole::data(const QModelIndex& sourceIndex,
                              const QQmlSortFilterProxyModel& proxyModel)
{
    Q_UNUSED(proxyModel)
    return m_selectionModel->isSourceIndexSelected(sourceIndex);
}

SelectableSortFilterProxyModel::SelectableSortFilterProxyModel(QObject* parent) :
    QQmlSortFilterProxyModel(parent)
{
    appendProxyRole(m_isSelectedRole.data());

    m_selectedKeys.reserve(count());
    connect(this, &SelectableSortFilterProxyModel::countChanged,
            this, [&](){ m_selectedKeys.reserve(count()); });
    connect(this, &SelectableSortFilterProxyModel::countChanged,
            this, &SelectableSortFilterProxyModel::updateFilteredSelectedCount);
    connect(this, &SelectableSortFilterProxyModel::selectedCountChanged,
            this, &SelectableSortFilterProxyModel::updateFilteredSelectedCount);
}

bool SelectableSortFilterProxyModel::isSourceIndexSelected(
        const QModelIndex& sourceIndex) const
{
    if (!sourceIndex.isValid()) return false;
    int keyRole = getKeyRole();
    if (keyRole < 0) return false;

    const auto& key = sourceData(sourceIndex, keyRole);
    return m_selectedMap.value(key, false);
}

int SelectableSortFilterProxyModel::getKeyRole() const
{
    return roleForName(m_selectionKey);
}

void SelectableSortFilterProxyModel::selectItem(const QModelIndex& index)
{
    if (!index.isValid()) return;
    int keyRole = getKeyRole();
    if (keyRole < 0) return;

    const auto& key = data(index, keyRole);
    if (m_selectedMap.value(key, false) == true) return;

    m_selectedCount += 1;
    m_selectedKeys.append(key);
    m_selectedMap[key] = true;

    emit selectedCountChanged();
    emit selectedKeysChanged();
    emit itemSelected(key);
    emit dataChanged(index, index, {roleForName(m_isSelectedRole->name())});
}

void SelectableSortFilterProxyModel::selectItem(int row)
{
    selectItem(index(row, 0));
}

void SelectableSortFilterProxyModel::deselectItem(const QModelIndex& index)
{
    if (!index.isValid()) return;
    int keyRole = getKeyRole();
    if (keyRole < 0) return;

    const auto& key = data(index, keyRole);
    if (m_selectedMap.value(key, false) == false) return;

    m_selectedCount -= 1;
    m_selectedKeys.removeAll(key);
    m_selectedMap[key] = false;

    emit selectedCountChanged();
    emit selectedKeysChanged();
    emit itemDeselected(key);
    emit dataChanged(index, index, {roleForName(m_isSelectedRole->name())});
}

void SelectableSortFilterProxyModel::deselectItem(int row)
{
    deselectItem(index(row, 0));
}

void SelectableSortFilterProxyModel::toggleSelection(const QModelIndex& index)
{
    if (!index.isValid()) return;
    int keyRole = getKeyRole();
    if (keyRole < 0) return;

    const auto& key = data(index, keyRole);

    if (m_selectedMap.value(key, false) == true) {
        deselectItem(index);
    } else {
        selectItem(index);
    }
}

void SelectableSortFilterProxyModel::toggleSelection(int row)
{
    toggleSelection(index(row, 0));
}

void SelectableSortFilterProxyModel::selectAll()
{
    int keyRole = getKeyRole();
    if (keyRole < 0) return;

    for (int i = count() - 1; i >= 0; --i) {
        QModelIndex idx = index(i, 0);

        const auto& key = data(idx, keyRole);
        if (m_selectedMap.value(key, false) == true) continue;

        m_selectedCount += 1;
        m_selectedKeys.append(key);
        m_selectedMap[key] = true;

        emit itemSelected(key);
        emit dataChanged(idx, idx, {roleForName(m_isSelectedRole->name())});
    }

    emit selectedCountChanged();
    emit selectedKeysChanged();
}

void SelectableSortFilterProxyModel::clearCurrent()
{
    int keyRole = getKeyRole();
    if (keyRole < 0) return;

    for (int i = count() - 1; i >= 0; --i) {
        QModelIndex idx = index(i, 0);

        const auto& key = data(idx, keyRole);
        if (m_selectedMap.value(key, false) == false) continue;

        m_selectedCount -= 1;
        m_selectedKeys.removeAll(key);
        m_selectedMap[key] = false;

        emit itemDeselected(key);
        emit dataChanged(idx, idx, {roleForName(m_isSelectedRole->name())});
    }

    emit selectedCountChanged();
    emit selectedKeysChanged();
}

void SelectableSortFilterProxyModel::clearAll()
{
    m_selectedMap.clear();
    m_selectedKeys.clear();
    m_selectedCount = 0;

    emit selectedCountChanged();
    emit selectedKeysChanged();
    emit dataChanged(index(0, 0), index(rowCount(), columnCount()),
                     {roleForName(m_isSelectedRole->name())});
}

void SelectableSortFilterProxyModel::selectKeys(const QVariantList& keys)
{
    int keyRole = getKeyRole();
    if (keyRole < 0) return;

    QMap<QVariant, QModelIndex> indexByKey;

    QList<int> updated;
    updated.reserve(keys.length());

    for (int i = keys.length() - 1; i >= 0; --i) {
        const auto& key = keys[i];
        if (m_selectedMap.value(key, false) == true) continue;

        updated.append(i);
        m_selectedCount += 1;
        m_selectedKeys.append(key);
        m_selectedMap[key] = true;
    }

    if (updated.length() > 0) {
        for (int i = count() - 1; i >= 0; --i) {
            QModelIndex idx = index(i, 0);
            const auto& key = data(idx, keyRole);
            indexByKey[key] = idx;
        }

        for (const auto& i : updated) {
            const auto& key = keys[i];
            const auto& idx = indexByKey[key];

            emit itemSelected(key);
            emit dataChanged(idx, idx, {roleForName(m_isSelectedRole->name())});
        }
    }

    emit selectedCountChanged();
    emit selectedKeysChanged();
}

void SelectableSortFilterProxyModel::updateFilteredSelectedCount()
{
    int keyRole = getKeyRole();
    if (keyRole < 0) return;

    m_filteredSelectedCount = 0;

    for (int i = count() - 1; i >= 0; --i) {
        const auto& key = data(index(i, 0), keyRole);

        if (m_selectedMap.value(key, false) == true) {
            m_filteredSelectedCount += 1;
        }
    }

    emit filteredSelectedCountChanged();
}

}
