/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.6
import Sailfish.Silica 1.0
import SortFilterProxyModel 0.2
import io.thp.pyotherside 1.5
import "../components"

Dialog {
    id: root

    property var selected: ([])
    readonly property int _selectedCount: filteredModel.selectedCount
    readonly property int _filteredSelectedCount: filteredModel.filteredSelectedCount
    property var _searchQueryDialog: null

    allowedOrientations: Orientation.All
    canAccept: _selectedCount > 0

    onAccepted: {
        selected = filteredModel.selectedKeys
    }

    SearchModel {
        id: filteredModel
        queries: SearchQueriesData {}
    }

    DiaryListView {
        id: listView
        anchors.fill: parent
        model: filteredModel
        showFullEntries: false
        selectable: true

        PullDownMenu {
            flickable: listView

            MenuItem {
                text: qsTr("Clear selection")
                visible: _filteredSelectedCount > 0
                onDelayedClick: filteredModel.clearCurrent()
            }
            MenuItem {
                text: listView.showFullEntries ?
                          qsTr("Show previews") :
                          qsTr("Show full entries")
                onDelayedClick: {
                    listView.showFullEntries = !listView.showFullEntries
                }
            }
            MenuItem {
                text: qsTr("Select all")
                visible: _filteredSelectedCount < filteredModel.count
                onDelayedClick: filteredModel.selectAll()
            }
            MenuItem {
                text: qsTr("Filter")
                onClicked: {
                    if (_searchQueryDialog === null) {
                        _searchQueryDialog = pageStack.push(
                            Qt.resolvedUrl("SearchQueryDialog.qml"), {
                            // TODO activeQueries: filteredModel.queries,
                            enableFilterSelected: true,
                        })
                    } else {
                        pageStack.push(_searchQueryDialog, {
                            // TODO activeQueries: filteredModel.queries,
                            enableFilterSelected: true,
                        })
                    }
                }
            }
        }

        header: DialogHeader {
            id: header
            acceptText: qsTr("Select %n", "", _selectedCount)

            Label {
                parent: header.extraContent
                anchors.centerIn: parent
                // TODO improve text, only show when filters are active,
                //      support editing filters
                visible: filteredModel.count !== appWindow.rawModel.count
                text: qsTr("%n entries shown", "", filteredModel.count)
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryHighlightColor
                horizontalAlignment: Text.AlignHCenter
                width: Theme.itemSizeHuge
                wrapMode: Text.Wrap
            }
        }

        ViewPlaceholder {
            enabled: filteredModel.count === 0
            text: qsTr("No entries found")
        }
    }
}
