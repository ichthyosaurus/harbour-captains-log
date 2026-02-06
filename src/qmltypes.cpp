/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "tagsfilter.h"
#include "selectable_sfpm.h"

#include <QtQml>
#include <QCoreApplication>

void registerQmlTypes() {
    qmlRegisterType<qqsfpm::TagsFilter>(
        "Opal.SortFilterProxyModel", 1, 0, "TagsFilter");
    qmlRegisterType<qqsfpm::SelectableSortFilterProxyModel>(
        "Opal.SortFilterProxyModel", 1, 0, "SelectableSortFilterProxyModel");
}

Q_COREAPP_STARTUP_FUNCTION(registerQmlTypes)
