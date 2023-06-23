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
    property string _filterQuery
    readonly property int _selectedCount: filteredModel.selectedCount /*!!listView.selectionModel ?
        listView.selectionModel.count : 0*/

    allowedOrientations: Orientation.All
    canAccept: _selectedCount > 0

//    WorkerScript {
//        id: selectionWorker
//        source: "../components/selection_worker.js"
//        onMessage: {
//            console.log("MSG", JSON.stringify(messageObject))
//            listView.selectionModel.reset(messageObject.dict, messageObject.count)
//            loadingIndicator.running = false
//        }
//    }

//    Python {
//        id: selectionPy

//        onError: {
//            console.error('python error:', traceback)
//        }

//        function selectAll() {
//            importModule('tools', function(){
//                console.log("starting tool")
//                selectionPy.call('tools.select_all',
//                    [listView.selectionModel.selected,
//                     filteredModel, _selectedCount], function(result){
//                    console.log("RESULT", JSON.stringify(result))
//                })
//            })
//        }

//        Component.onCompleted: {
//            addImportPath(Qt.resolvedUrl('../py'))
//        }
//    }

    SearchModel {
        id: filteredModel
        queries: SearchQueriesData {

        }
    }

//    BusyLabel {
//        id: loadingIndicator
//        text: qsTr("Selecting")
//        running: false

////        signal selectAll
////        signal _doSelectAll
////        signal done

////        onSelectAll: {
////            running = true
////            _doSelectAll()
////        }

////        on_DoSelectAll: {
////            if (!listView.selectionModel) {
////                return
////            }

////            for (var i = 0; i < filteredModel.count; ++i) {
////                var rowid = filteredModel.get(i).rowid
////                listView.selectionModel.select(rowid)
////            }

////            done()
////        }

////        onDone: {
////            running = false
////        }
//    }

    Binding on backNavigation {
        when: loadingIndicator.running
        value: false
    }

//    ListModel {
//        id: dummy
//    }

    DiaryListView {
        id: listView
        anchors.fill: parent
        model: /*loadingIndicator.running ?
                   null :*/ filteredModel
        showFullEntries: false
        selectable: true

        PullDownMenu {
            flickable: listView
            enabled: !loadingIndicator.running

            MenuItem {
                text: qsTr("Clear selection")
                visible: _selectedCount > 0
                onClicked: {
                    filteredModel.clearCurrent()
//                    if (!!listView.selectionModel) {
//                        listView.selectionModel.clear()
//                    }
                }
            }
            MenuItem {
                text: qsTr("Select all")
                visible: filteredModel.count > 0
                onDelayedClick: {
                    console.log("start")
//                    selectionPy.selectAll()

                    filteredModel.selectAll()

//                    loadingIndicator.running = true

//                    dummy.clear()  // it's not possible to pass a SFPM to the worker, only ListModel
//                    for (var i = 0; i < filteredModel.count; ++i) {
//                        dummy.append({rowid: filteredModel.get(i).rowid})
//                    }

//                    selectionWorker.sendMessage({
//                        dict: listView.selectionModel.selected,
//                        model: dummy,
//                        count: listView.selectionModel.count,
//                    })

//                    for (var i = 0; i < filteredModel.count; ++i) {
//                        var rowid = filteredModel.get(i).rowid
//                    }

//                    loadingIndicator.selectAll()
                    console.log("done")

//                    if (!listView.selectionModel) {
//                        return
//                    }

//                    console.log("start")
//                    loadingIndicator.running = true

//                    var selected = ({})
//                    for (var i = 0; i < filteredModel.count; ++i) {
//                        var rowid = filteredModel.get(i).rowid
//                        listView.selectionModel.select(rowid)
//                    }

//                    loadingIndicator.running = false
//                    console.log("done")
                }
            }
            MenuItem {
                text: listView.showFullEntries ?
                          qsTr("Show previews") :
                          qsTr("Show full entries")
                onDelayedClick: {
                    listView.showFullEntries = !listView.showFullEntries
                }
            }
        }

        header: Column {
            height: childrenRect.height
            width: root.width

            DialogHeader {
                acceptText: qsTr("Select %n", "", _selectedCount)
            }

            SearchField {
                onTextChanged: root._filterQuery = text
            }
        }

        ViewPlaceholder {
            enabled: filteredModel.count === 0
            text: qsTr("No entries found")
        }
    }
}
