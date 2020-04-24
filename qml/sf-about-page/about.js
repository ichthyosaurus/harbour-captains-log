.pragma library

// This script is a library. This improves performance, but it means that no
// variables from the outside can be accessed.

var DEVELOPMENT = [
    {label: qsTr("Programming"), values: ["Gabriel Berkigt", "Mirian Margiani"]},
    {label: qsTr("Icon Design"), values: ["Gabriel Berkigt", "Mirian Margiani"]},
]

var TRANSLATIONS = [
    {label: qsTr("English"), values: ["Gabriel Berkigt"]},
    {label: qsTr("Swedish"), values: ["Åke Engelbrektson"]},
    {label: qsTr("German"), values: ["Gabriel Berkigt", "Mirian Margiani"]},
]

var VERSION_NUMBER // set in main.qml's Component.onCompleted
var APPINFO = {
    appName: "Captain's Log",
    iconPath: "/usr/share/icons/hicolor/172x172/apps/harbour-captains-log.png",
    description: qsTr("A simple diary application for keeping track of your thoughts."),
    author: "Gabriel Berkigt",
    sourcesLink: "http://www.github.com/AlphaX2/Captains-Log",
    sourcesText: qsTr("Sources on GitHub"),

    extraInfoTitle: "",
    extraInfoText: "",
    extraInfoLink: "mailto: m.gabrielboehme@googlemail.com" +
                   "?subject=[Captain's Log] %1".arg(qsTr("Feedback", "feedback email subject line")),
    extraInfoLinkText: qsTr("Send Feedback"),

    enableContributorsPage: true, // whether to enable 'ContributorsPage.qml'
    contribDevelopment: DEVELOPMENT,
    contribTranslations: TRANSLATIONS,

    shortLicenseText: "GNU GPL version 3.\n" +
                      "This is free software: you are free to change and redistribute it." +
                      "There is NO WARRANTY, to the extent permitted by law."
}

function aboutPageUrl() {
    return Qt.resolvedUrl("AboutPage.qml");
}

function pushAboutPage(pageStack) {
    APPINFO.versionNumber = VERSION_NUMBER;
    pageStack.push(aboutPageUrl(), APPINFO);
}
