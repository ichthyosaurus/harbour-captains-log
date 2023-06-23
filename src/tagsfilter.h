/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef TAGSFILTER_H
#define TAGSFILTER_H

#include "../libs/SortFilterProxyModel/filters/rolefilter.h"
#include <QVariant>

namespace qqsfpm {

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
