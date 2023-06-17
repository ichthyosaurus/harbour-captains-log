//@ This file is part of opal-infocombo.
//@ https://github.com/Pretty-SFOS/opal-infocombo
//@ SPDX-FileCopyrightText: 2023 Mirian Margiani
//@ SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick 2.2
import Sailfish.Silica 1.0
Page{id:root
allowedOrientations:Orientation.All
property string title
property var sections:[]
property bool hasExtraSections:false
property var linkHandler:function(link){Qt.openUrlExternally(link)
}
SilicaFlickable{id:flick
anchors.fill:parent
contentHeight:column.height+2*Theme.horizontalPageMargin
VerticalScrollDecorator{flickable:flick
}Column{id:column
spacing:Theme.paddingLarge
width:parent.width
height:childrenRect.height
PageHeader{title:root.title
description:qsTranslate("Opal.InfoCombo","Details")
}Repeater{model:sections
delegate:Column{width:parent.width
spacing:Theme.paddingSmall
height:childrenRect.height
Item{width:1
height:Theme.paddingMedium
}Label{width:parent.width-2*x
x:Theme.horizontalPageMargin
horizontalAlignment:Text.AlignRight
font.pixelSize:Theme.fontSizeSmall
truncationMode:TruncationMode.Fade
color:palette.highlightColor
linkColor:palette.primaryColor
text:modelData.title
onLinkActivated:modelData.linkHandler(link)
}Label{width:parent.width-2*x
x:Theme.horizontalPageMargin
horizontalAlignment:Text.AlignRight
font.pixelSize:Theme.fontSizeSmall
font.italic:true
truncationMode:TruncationMode.Fade
color:palette.secondaryHighlightColor
linkColor:palette.primaryColor
visible:!!modelData.isOption&&root.hasExtraSections
text:qsTranslate("Opal.InfoCombo","Option")
onLinkActivated:modelData.linkHandler(link)
}Label{width:parent.width-2*x
x:Theme.horizontalPageMargin
font.pixelSize:Theme.fontSizeSmall
color:Theme.highlightColor
linkColor:palette.primaryColor
wrapMode:Text.Wrap
text:modelData.text
onLinkActivated:modelData.linkHandler(link)
}}}}}}