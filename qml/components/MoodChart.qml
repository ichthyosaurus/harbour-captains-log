/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2024 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.6
import Sailfish.Silica 1.0

import "../qchart/"
import "../qchart/QChart.js" as Charts

QChart {
    property var dataGetter: function(){}

    chartAnimated: false
    chartData: { 'labels': ['', '', '', '', '', '', ''], 'datasets': [
        { data: [2, 2, 2, 2, 2, 2, 2, 2] }
    ]}

    chartType: Charts.ChartType.LINE
    chartOptions: ({
        scaleFontSize: Theme.fontSizeExtraSmall * (4/5),
        scaleFontFamily: 'Sail Sans Pro',
        scaleFontColor: Theme.secondaryColor,
        scaleLineColor: Theme.secondaryColor,
        scaleOverlay: false,
        bezierCurve: false,
        datasetStrokeWidth: 2,
        datasetFill: false,
        datasetFillDiff23: true,
        pointDotRadius: 6,
        currentHourLine: false,
        asOverview: false,

        scaleOverride: true,
        scaleStartValue: 0,
        scaleStepWidth: 1,
        scaleSteps: 5,
        scaleShowGridLines: true,

        fillColor:        ["rgba(255, 195, 77,0)", "rgba(255, 195, 77,0.2)", "rgba(255, 195, 77,0.2)"],
        strokeColor:      ["rgba(255, 195, 77,1)", "rgba(255, 195, 77,0.6)", "rgba(255, 195, 77,0.6)"],
        pointColor:       ["rgba(255, 195, 77,1)", "rgba(255, 195, 77,0.3)", "rgba(255, 195, 77,0.3)"],
        pointStrokeColor: ["rgba(255, 195, 77,1)", "rgba(255, 195, 77,0.3)", "rgba(255, 195, 77,0.3)"],
    })

    Component.onCompleted: {
        dataGetter()
    }
}
