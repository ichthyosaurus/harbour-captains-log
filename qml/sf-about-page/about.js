.pragma library
// This script is a library. This improves performance, but it means that no
// variables from the outside can be accessed.


// -- TRANSLATORS
// Please add yourself to the list of contributors. If your language is already
// in the list, add your name to the 'values' field:
//     example: {label: qsTr("Your language"), values: ["Existing contributor", "YOUR NAME HERE"]},
//
// If you added a new translation, create a new section at the top of the list:
//     example:
//          var TRANSLATIONS = [
//              {label: qsTr("Your language"), values: ["YOUR NAME HERE"]},
//          [...]
//
var TRANSLATIONS = [
    {label: qsTr("English"), values: ["Gabriel Berkigt"]},
    {label: qsTr("Swedish"), values: ["Åke Engelbrektson"]},
    {label: qsTr("German"), values: ["Gabriel Berkigt", "Mirian Margiani"]},
]


// -- OTHER CONTRIBUTORS
// Please add yourself the the list of contributors.
var DEVELOPMENT = [
    {label: qsTr("Programming"), values: ["Gabriel Berkigt", "Mirian Margiani"]},
    {label: qsTr("Icon Design"), values: ["Gabriel Berkigt", "Mirian Margiani"]},
]

var VERSION_NUMBER // set in main.qml's Component.onCompleted
var APPINFO = {
    _aboutPageTitle: qsTr("About Captain's Log"),
    iconPath: "/usr/share/icons/hicolor/172x172/apps/harbour-captains-log.png",
    description: qsTr("A simple diary application for keeping track of your thoughts."),
    _authorSectionTitle: qsTr("Authors"),
    author: ["Gabriel Berkigt", "Mirian Margiani", "―", qsTr("Swedish: %1").arg("Åke Engelbrektson")].join('\n'),
    sourcesLink: "http://www.github.com/AlphaX2/Captains-Log",
    sourcesText: qsTr("Sources on GitHub"),
    extraInfoTitle: "",
    extraInfoText: "",
    enableContributorsPage: false, // whether to enable 'ContributorsPage.qml'
    contribDevelopment: DEVELOPMENT,
    contribTranslations: TRANSLATIONS,
    // shortLicenseText: "..." // no need to configure, as GPL v3 is the default
}

function aboutPageUrl() {
    return Qt.resolvedUrl("AboutPage.qml");
}

function pushAboutPage(pageStack) {
    APPINFO.versionNumber = VERSION_NUMBER;
    pageStack.push(aboutPageUrl(), APPINFO);
}
