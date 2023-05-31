/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.6
import SortFilterProxyModel 0.2

// Requires appWindow.rawModel and appWindow.parseDate in the context.

SortFilterProxyModel {
    id: root
    sourceModel: appWindow.rawModel

    property SearchQueriesData queries: SearchQueriesData {}

    proxyRoles: ExpressionRole {
        name: "calculatedDate"
        expression: appWindow.parseDate(model.create_date)
    }

    filters: [
        AnyOf {
            enabled: !queries.matchAllMode
        },

        AllOf {
            enabled: queries.matchAllMode

            AnyOf {
                enabled: !!queries.text

                RegExpFilter {
                    caseSensitivity: Qt.CaseInsensitive
                    syntax: queries.textMatchMode
                    pattern: queries.text
                    roleName: "title"
                }
                RegExpFilter {
                    caseSensitivity: Qt.CaseInsensitive
                    syntax: queries.textMatchMode
                    pattern: queries.text
                    roleName: "entry"
                }
            }

            RangeFilter {
                roleName: "calculatedDate"
                minimumValue: queries.dateMin
                maximumValue: queries.dateMax
            }

            ValueFilter {
                enabled: queries.bookmark !== Qt.PartiallyChecked
                roleName: "bookmark"
                value: queries.bookmark === Qt.Checked ? 1 : 0
            }

            RegExpFilter {
                enabled: !!queries.tags
                caseSensitivity: Qt.CaseInsensitive
                syntax: queries.textMatchMode
                pattern: queries.tags
                roleName: "tags"
            }

            RangeFilter {
                enabled: queries.moodMin >= 0 && queries.moodMax >= 0
                minimumValue: queries.moodMin
                maximumValue: queries.moodMax
                roleName: "mood"
            }
        }
    ]
}
