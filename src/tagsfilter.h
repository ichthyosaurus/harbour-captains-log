/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef TAGSFILTER_H
#define TAGSFILTER_H

#include "../libs/SortFilterProxyModel/filters/rolefilter.h"
#include "../libs/SortFilterProxyModel/qqmlsortfilterproxymodel.h"
#include "../libs/SortFilterProxyModel/proxyroles/singlerole.h"
#include "property_macros.h"

#include <QVariant>
#include <QMap>
#include <QVariantList>

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

private:
    QMap<QVariant, bool> m_selectedMap;
    QSharedPointer<IsSelectedRole> m_isSelectedRole {new IsSelectedRole(this)};
};


class TagsFilter : public RoleFilter {
    Q_OBJECT
    Q_PROPERTY(QStringList tags READ tags WRITE setTags NOTIFY tagsChanged)
    Q_PROPERTY(QString separator READ separator WRITE setSeparator NOTIFY separatorChanged)
    Q_PROPERTY(bool matchAll READ matchAll WRITE setMatchAll NOTIFY matchAllChanged)
    Q_PROPERTY(Qt::CaseSensitivity caseSensitivity READ caseSensitivity WRITE setCaseSensitivity NOTIFY caseSensitivityChanged)

public:
    using RoleFilter::RoleFilter;

    QStringList tags() const;
    void setTags(const QStringList& tags);

    QString separator() const;
    void setSeparator(const QString& separator);

    bool matchAll() const;
    void setMatchAll(bool matchAll);

    Qt::CaseSensitivity caseSensitivity() const;
    void setCaseSensitivity(Qt::CaseSensitivity caseSensitivity);

protected:
    bool filterRow(const QModelIndex& sourceIndex, const QQmlSortFilterProxyModel& proxyModel) const override;

Q_SIGNALS:
    void tagsChanged();
    void separatorChanged();
    void matchAllChanged();
    void caseSensitivityChanged();

private:
    QStringList m_tags {};
    QStringList m_tags_lower {};
    QString m_separator {QStringLiteral(",")};
    bool m_matchAll {true};
    Qt::CaseSensitivity m_caseSensitivity {Qt::CaseSensitive};
};

}

#endif // TAGSFILTER_H
