#include "tagsfilter.h"
#include <QDebug>

namespace qqsfpm {

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
