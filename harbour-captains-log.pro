# This file is part of Captain's Log.
# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2020 Gabriel Berkigt
# SPDX-FileCopyrightText: 2020-2024 Mirian Margiani

# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-captains-log

CONFIG += sailfishapp c++11
# LIBS += -licui18n -licuuc  <<< not allowed in Harbour

SOURCES += \
    src/harbour-captains-log.cpp \
    src/qmltypes.cpp \
    src/tagsfilter.cpp \
    src/selectable_sfpm.cpp \
    # src/transliterator.cpp \

HEADERS += \
    src/property_macros.h \
    src/tagsfilter.h \
    src/selectable_sfpm.h \
    # src/transliterator.h \

DISTFILES += \
    qml/harbour-captains-log.qml \
    qml/cover/*.qml \
    qml/images/*.png \
    qml/pages/*.qml \
    qml/components/*.qml \
    qml/templates/* \
    qml/py/*.py \
    rpm/harbour-captains-log.changes.in \
    rpm/harbour-captains-log.changes.run.in \
    rpm/harbour-captains-log.spec \
    rpm/harbour-captains-log.yaml \
    translations/*.ts \
    harbour-captains-log.desktop \
    \
    qml/qchart/*.qml \
    qml/qchart/*.js \

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# Do not forget to modify the localized app name
# in the the .desktop file.
TRANSLATIONS = translations/harbour-captains-log-*.ts \

# Note: version number is configured in yaml
DEFINES += APP_VERSION=\\\"$$VERSION\\\"
DEFINES += APP_RELEASE=\\\"$$RELEASE\\\"
include(libs/opal-cached-defines.pri)

include(libs/opal.pri)
