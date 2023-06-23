/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "tagsfilter.h"

#include "../libs/SortFilterProxyModel/proxyroles/singlerole.h"

#include <QDebug>

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
}

bool SelectableSortFilterProxyModel::isSourceIndexSelected(const QModelIndex& sourceIndex) const
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

    for (int i = count(); i >= 0; --i) {
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

    for (int i = count(); i >= 0; --i) {
        QModelIndex idx = index(i, 0);

        const auto& key = data(idx, keyRole);
        if (m_selectedMap.value(key, false) == false) return;

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

/*!
    \qmltype TagsFilter
    \inherits RoleFilter
    \inqmlmodule SortFilterProxyModel
    \ingroup Filters
    \brief  Filters rows matching a list of tags.

    A TagsFilter is a \l RoleFilter that accepts rows matching a list of tags.
*/

QStringList TagsFilter::tags() const
{
    return m_tags;
}

void TagsFilter::setTags(const QStringList& tags)
{
    QStringList cleaned = tags;
    cleaned.removeDuplicates();

    QMutableStringListIterator it(cleaned);
    while (it.hasNext()) {
        const auto& value = it.next().trimmed();

        if (value.isEmpty()) {
            it.remove();
        } else {
            it.setValue(value);
        }
    }

    if (m_tags == cleaned) {
        return;
    }

    m_tags = cleaned;

    m_tags_lower.clear();
    m_tags_lower.reserve(m_tags.length());

    for (const auto& i : m_tags) {
        m_tags_lower.append(i.toLower());
    }

    Q_EMIT tagsChanged();
    invalidate();
}

QString TagsFilter::separator() const
{
    return m_separator;
}

void TagsFilter::setSeparator(const QString& separator)
{
    if (m_separator == separator) {
        return;
    }

    m_separator = separator;
    Q_EMIT separatorChanged();
    invalidate();
}

bool TagsFilter::matchAll() const
{
    return m_matchAll;
}

void TagsFilter::setMatchAll(bool matchAll)
{
    if (m_matchAll == matchAll) {
        return;
    }

    m_matchAll = matchAll;
    Q_EMIT matchAllChanged();

    if (m_tags.length() > 1) {
        invalidate();
    }
}

/*!
    \qmlproperty Qt::CaseSensitivity TagsFilter::caseSensitivity

    This property holds the caseSensitivity of the filter.
*/
Qt::CaseSensitivity TagsFilter::caseSensitivity() const
{
    return m_caseSensitivity;
}

void TagsFilter::setCaseSensitivity(Qt::CaseSensitivity caseSensitivity)
{
    if (m_caseSensitivity == caseSensitivity)
        return;

    m_caseSensitivity = caseSensitivity;
    Q_EMIT caseSensitivityChanged();
    invalidate();
}

bool TagsFilter::filterRow(const QModelIndex& sourceIndex,
                           const QQmlSortFilterProxyModel& proxyModel) const
{
    QString string = sourceData(sourceIndex, proxyModel).toString();
    const QStringList* tags = &m_tags;

    if (m_caseSensitivity == Qt::CaseInsensitive) {
        string = string.toLower();
        tags = &m_tags_lower;
    }

    QStringList parts = string.split(m_separator);
    QMutableStringListIterator it(parts);

    while (it.hasNext()) {
        const auto& value = it.next().trimmed();

        if (value.isEmpty()) {
            it.remove();
        } else {
            it.setValue(value);
        }
    }

    if (m_matchAll) {
        for (const auto& i : *tags) {
            if (!parts.contains(i)) {
                return false;
            }
        }
    } else {
        for (const auto& i : *tags) {
            if (parts.contains(i)) {
                return true;
            }
        }
    }

    return m_matchAll;
}

}
