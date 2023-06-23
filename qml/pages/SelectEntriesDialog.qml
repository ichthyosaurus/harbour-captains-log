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
                    var dialog = pageStack.push(
                        Qt.resolvedUrl("SearchQueryDialog.qml"),
                        {enableFilterSelected: true})
                    dialog.resetQueries(filteredModel.queries)
                    dialog.accepted.connect(function(){
                        dialog.copyQueries(dialog.activeQueries,
                                           filteredModel.queries)
                    })
                }
            }
        }

        header: DialogHeader {
            id: header
            acceptText: qsTr("Select %n", "", _selectedCount)

            Label {
                parent: header.extraContent
                anchors.centerIn: parent
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
