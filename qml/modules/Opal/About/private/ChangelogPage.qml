//@ This file is part of opal-about.
//@ https://github.com/Pretty-SFOS/opal-about
//@ SPDX-FileCopyrightText: 2023 Mirian Margiani
//@ SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.2
import Sailfish.Silica 1.0
import ".."

Page {
    id: root
    property list<Changelog> changelogItems
    property url changelogList
    property string appName

    allowedOrientations: Orientation.All

    // Copy of AboutPageBase::openOrCopyUrl to ensure it is available.
    function openOrCopyUrl(externalUrl, title) {
        pageStack.push(Qt.resolvedUrl("ExternalUrlPage.qml"),
            {'externalUrl': externalUrl, 'title': !!title ? title : ''})
    }

    Component.onCompleted: {
        if (changelogList != "" && changelogItems.length > 0) {
            console.error("[Opal.About] programming error: it is not allowed to define " +
                          "both changelogItems and changelogList. Changelog items in " +
                          "the changelog list '%1' will not be shown.".arg(changelogList))
            changelogList = ""
        }
    }

    Loader {
        id: changelogListLoader
        asynchronous: true
        source: changelogList

        onStatusChanged: {
            if (status === Loader.Ready) {
                if (!item.hasOwnProperty('__is_opal_about_changelog_list') ||
                        !item.hasOwnProperty('changelogItems')) {
                    console.error("[Opal.About] programming error: changelogList must be " +
                                  "a reference to a valid ChangelogList component")
                } else {
                    changelogItems = item.changelogItems
                }
            }
        }
    }

    SilicaListView {
        id: flick
        anchors.fill: parent
        quickScroll: !_scrollbar
        spacing: Theme.paddingMedium

        property Item _scrollbar: null

        VerticalScrollDecorator {
            flickable: flick
            visible: !flick._scrollbar
        }

        Component.onCompleted: {
            try {
                _scrollbar = Qt.createQmlObject("
                    import QtQuick 2.0
                    import %1 1.0 as Private
                    Private.Scrollbar {
                        text: flick.currentSection.split('|')[0]
                        description: flick.currentSection.split('|').slice(1).join('|')
                        headerHeight: flick.headerItem ? flick.headerItem.height : 0
                    }".arg("Sailfish.Silica.private"), flick, 'Scrollbar')
            } catch (e) {
                if (!_scrollbar) {
                    console.warn(e)
                    console.warn('[Opal.About] bug: failed to load customized scrollbar')
                    console.warn('[Opal.About] bug: this probably means the private API has changed')
                }
            }
        }

        header: PageHeader {
            title: qsTranslate("Opal.About", "Changelog")
            description: appName
        }

        footer: Item { width: parent.width; height: Theme.horizontalPageMargin }

        model: changelogItems
        section.property: "__effectiveSection"

        delegate: Column {
            id: item
            width: root.width
            height: childrenRect.height
            spacing: Theme.paddingSmall

            property int textFormat: model.textFormat
            property var paragraphs: model.__effectiveEntries


            Item { width: 1; height: Theme.paddingMedium }

            Label {
                width: parent.width - 2*x
                x: Theme.horizontalPageMargin
                horizontalAlignment: Text.AlignRight
                font.pixelSize: Theme.fontSizeSmall
                truncationMode: TruncationMode.Fade
                color: palette.highlightColor
                text: model.version
            }

            Label {
                width: parent.width - 2*x
                x: Theme.horizontalPageMargin
                horizontalAlignment: Text.AlignRight
                font.pixelSize: Theme.fontSizeSmall
                font.italic: true
                truncationMode: TruncationMode.Fade
                color: palette.secondaryHighlightColor
                visible: haveAuthor || haveDate

                property bool haveAuthor: !!model.author
                property bool haveDate: !isNaN(model.date.valueOf())

                text: {
                    if (haveAuthor && haveDate) {
                        Qt.formatDate(model.date, Qt.DefaultLocaleShortDate) +
                              ", " + model.author
                    } else if (haveAuthor) {
                        model.author
                    } else if (haveDate) {
                        Qt.formatDate(model.date, Qt.DefaultLocaleShortDate)
                    } else {
                        ""
                    }
                }
            }

            Repeater {
                model: item.paragraphs

                Label {
                    width: parent.width - 2*x
                    x: Theme.horizontalPageMargin
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.highlightColor
                    wrapMode: Text.Wrap
                    textFormat: item.textFormat
                    text: modelData
                    linkColor: Theme.primaryColor
                    onLinkActivated: openOrCopyUrl(link)
                }
            }
        }
    }
}
