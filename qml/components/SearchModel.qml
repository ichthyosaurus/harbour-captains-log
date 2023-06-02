/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.6
import SortFilterProxyModel 0.2

// Requires appWindow.rawModel, appWindow.normalizeText, and appWindow.parseDate

SortFilterProxyModel {
    id: root
    sourceModel: appWindow.rawModel

    property SearchQueriesData queries: SearchQueriesData {}

    proxyRoles: ExpressionRole {
        name: "calculatedDate"
        expression: appWindow.parseDate(model.entry_date)
    }

    filters: [
        // NOTE: the filters in AnyOf{} and AllOf{} must be identical!

        AnyOf {
            enabled: !queries.matchAllMode

            AnyOf {
                enabled: !!queries.text

                RegExpFilter {
                    caseSensitivity: Qt.CaseInsensitive
                    syntax: queries.textMatchSyntax
                    pattern: queries.text
                    roleName: "title"
                }
                RegExpFilter {
                    caseSensitivity: Qt.CaseInsensitive
                    syntax: queries.textMatchSyntax
                    pattern: queries.text
                    roleName: "entry"
                }
                RegExpFilter {
                    enabled: queries.textMatchMode == queries.matchSimplified
                    caseSensitivity: Qt.CaseInsensitive
                    syntax: queries.textMatchSyntax
                    pattern: appWindow.normalizeText(queries.text)
                    roleName: "entry_normalized"
                }
            }

            RangeFilter {
                enabled: queries.dateMin.getTime() != queries.dateMinUnset.getTime() ||
                         queries.dateMax.getTime() != queries.dateMaxUnset.getTime()
                roleName: "calculatedDate"
                minimumValue: queries.dateMin
                maximumValue: queries.dateMax
            }

            ValueFilter {
                enabled: queries.bookmark !== Qt.PartiallyChecked
                roleName: "bookmark"
                value: queries.bookmark === Qt.Checked ? 1 : 0
            }

            AnyOf {
                enabled: !!queries.tags

                RegExpFilter {
                    caseSensitivity: Qt.CaseInsensitive
                    syntax: queries.textMatchSyntax
                    pattern: queries.tags
                    roleName: "tags"
                }
                RegExpFilter {
                    enabled: queries.textMatchMode == queries.matchSimplified
                    caseSensitivity: Qt.CaseInsensitive
                    syntax: queries.textMatchSyntax
                    pattern: appWindow.normalizeText(queries.tags)
                    roleName: "tags_normalized"
                }
            }

            RangeFilter {
                enabled: queries.moodMin >= 0 && queries.moodMax >= 0 &&
                         !(queries.moodMin == 0 &&
                           queries.moodMax == (appWindow.moodTexts.length - 1))
                minimumValue: queries.moodMin
                maximumValue: queries.moodMax
                roleName: "mood"
            }
        },

        AllOf {
            enabled: queries.matchAllMode

            AnyOf {
                enabled: !!queries.text

                RegExpFilter {
                    caseSensitivity: Qt.CaseInsensitive
                    syntax: queries.textMatchSyntax
                    pattern: queries.text
                    roleName: "title"
                }
                RegExpFilter {
                    caseSensitivity: Qt.CaseInsensitive
                    syntax: queries.textMatchSyntax
                    pattern: queries.text
                    roleName: "entry"
                }
                RegExpFilter {
                    enabled: queries.textMatchMode == queries.matchSimplified
                    caseSensitivity: Qt.CaseInsensitive
                    syntax: queries.textMatchSyntax
                    pattern: appWindow.normalizeText(queries.text)
                    roleName: "entry_normalized"
                }
            }

            RangeFilter {
                enabled: queries.dateMin.getTime() != queries.dateMinUnset.getTime() ||
                         queries.dateMax.getTime() != queries.dateMaxUnset.getTime()
                roleName: "calculatedDate"
                minimumValue: queries.dateMin
                maximumValue: queries.dateMax
            }

            ValueFilter {
                enabled: queries.bookmark !== Qt.PartiallyChecked
                roleName: "bookmark"
                value: queries.bookmark === Qt.Checked ? 1 : 0
            }

            AnyOf {
                enabled: !!queries.tags

                RegExpFilter {
                    caseSensitivity: Qt.CaseInsensitive
                    syntax: queries.textMatchSyntax
                    pattern: queries.tags
                    roleName: "tags"
                }
                RegExpFilter {
                    enabled: queries.textMatchMode == queries.matchSimplified
                    caseSensitivity: Qt.CaseInsensitive
                    syntax: queries.textMatchSyntax
                    pattern: appWindow.normalizeText(queries.tags)
                    roleName: "tags_normalized"
                }
            }

            RangeFilter {
                enabled: queries.moodMin >= 0 && queries.moodMax >= 0 &&
                         !(queries.moodMin == 0 &&
                           queries.moodMax == (appWindow.moodTexts.length - 1))
                minimumValue: queries.moodMin
                maximumValue: queries.moodMax
                roleName: "mood"
            }
        }
    ]
}
