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
    qmlRegisterType<qqsfpm::TagsFilter>("SortFilterProxyModel", 0, 2, "TagsFilter");
    qmlRegisterType<qqsfpm::SelectableSortFilterProxyModel>(
        "SortFilterProxyModel", 0, 2, "SelectableSortFilterProxyModel");
}

Q_COREAPP_STARTUP_FUNCTION(registerQmlTypes)
