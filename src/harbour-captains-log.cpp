/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2021  Lukáš Karas
 * SPDX-FileCopyrightText: 2021-2022  Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include <QtQuick>
#include <QDebug>
#include <sailfishapp.h>
#include "requires_defines.h"

// TODO define these file names somewhere less ugly
#define DB_DATA_FILE QStringLiteral("logbook.db")
#define DB_VERSION_FILE QStringLiteral("schema_version")

namespace {
    bool migrateItem(const QString& oldLocation, const QString& newLocation)
    {
        // Based on Migration.cpp from OSMScout for SFOS.
        // GPL-2.0-or-later, 2021  Lukáš Karas
        // https://github.com/Karry/osmscout-sailfish/blob/35c12584e7016fc3651b36ef7c2b6a0898fd4ce1/src/Migration.cpp

        qDebug() << "Considering migration" << oldLocation << "to" << newLocation;
        QFileInfo oldInfo(oldLocation);
        QFileInfo newInfo(newLocation);

        if (oldInfo.exists() && !newInfo.exists()) {
            QDir parent = newInfo.dir();

            if (!parent.mkpath(parent.absolutePath())) {
                qWarning() << "Failed to create path" << parent.absolutePath();
                return false;
            }

            if (!QFile::rename(oldLocation, newLocation)) {
                qWarning() << "Failed to move" << oldLocation << "to" << newLocation;
                return false;
            }

            qDebug() << "Migrated" << oldLocation << "to" << newLocation;
            return true;
        }

        return false;
    }

    void runMigrations()
    {
        QString home = QStandardPaths::writableLocation(QStandardPaths::HomeLocation);
        bool success = true;

        // migration for Sailjail (SFOS 4.3)
        QString oldLocalDir = home + "/.local/share/harbour-captains-log";
        QString newLocalDir = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation);

        success = success && migrateItem(oldLocalDir + "/logbuch.db", newLocalDir + "/" + DB_DATA_FILE);
        success = success && migrateItem(oldLocalDir + "/" + DB_VERSION_FILE, newLocalDir + "/" + DB_VERSION_FILE);

        if (!success) {
            QString message = QStringLiteral(
                "Failed to migrate application data to new location.\n"
                "The application will now start normally but some data or configuration will be missing.\n"
                "Please close the app and move the files listed above manually.\n"
            );
        }
    }
}

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    app->setOrganizationName("harbour-captains-log"); // needed for Sailjail
    app->setApplicationName("harbour-captains-log");
    // runMigrations();

    QScopedPointer<QQuickView> view(SailfishApp::createView());
    view->rootContext()->setContextProperty("APP_VERSION", QString(APP_VERSION));
    view->rootContext()->setContextProperty("APP_RELEASE", QString(APP_RELEASE));
    view->rootContext()->setContextProperty("DB_DATA_FILE", DB_DATA_FILE);
    view->rootContext()->setContextProperty("DB_VERSION_FILE", DB_VERSION_FILE);

    view->engine()->addImportPath(SailfishApp::pathTo("qml/modules").toString());
    view->setSource(SailfishApp::pathToMainQml());
    view->show();
    return app->exec();
}
