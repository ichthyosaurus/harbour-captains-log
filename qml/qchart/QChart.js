// QChart.js ---
//
// Author: Julien Wintz
// Created: Thu Feb 13 14:37:26 2014 (+0100)
// Version:
// Last-Updated:
//           By:
//     Update #: 94
//

// Change Log:
//
//

// ADAPTED FOR HARBOUR-METEOSWISS
//
// Changes:
// - allow setting a minimum value in line graphs
// - remove all chart types except line and bar
// - use computed fixed width for y scale
// - align line chart dots and bar chart bars
// - add config option to draw a vertical indicator line based on the current time
// - use 'scaleOverlay' option to draw only the vertical scale
// - add option to line graph to only fill difference between second and third dataset
// - support setting colors when building the graph instead of inside the datasets
// - add options to overlay bars instead of plotting them side by side
// - add options for a special layout optimized for overlaying tiny bar and line plots
//

var ChartType = {
         BAR: 1,
        LINE: 3,
};

var Chart = function(canvas, context) {

    var chart = this;

// /////////////////////////////////////////////////////////////////
// Line helper
// /////////////////////////////////////////////////////////////////

    this.Line = function(data,options) {

        chart.Line.defaults = {
            scaleOverlay: false,
            scaleOverride: false,
            scaleSteps: null,
            scaleStepWidth: null,
            scaleStartValue: null,
            scaleLineColor: "rgba(0,0,0,.1)",
            scaleLineWidth: 1,
            scaleShowLabels: true,
            scaleLabel: "<%=value%>",
            scaleFontFamily: "'Arial'",
            scaleFontSize: 12,
            scaleFontStyle: "normal",
            scaleFontColor: "#666",
            scaleShowGridLines: true,
            scaleGridLineColor: "rgba(0,0,0,.05)",
            scaleGridLineWidth: 1,
            currentHourLine: false,
            bezierCurve: true,
            pointDot: true,
            pointDotRadius: 4,
            pointDotStrokeWidth: 2,
            datasetStroke: true,
            datasetStrokeWidth: 2,
            datasetFill: true,
            datasetFillDiff23: true,
            animation: true,
            animationSteps: 60,
            animationEasing: "easeOutQuart",
            onAnimationComplete: null,
            asOverview: false,

            fillColor: [],
            strokeColor: [],
            pointColor: [],
            pointStrokeColor: [],
        };

        var config = (options) ? mergeChartConfig(chart.Line.defaults,options) : chart.Line.defaults;

        return new Line(data,config,context);
    }

// /////////////////////////////////////////////////////////////////
// Bar helper
// /////////////////////////////////////////////////////////////////

    this.Bar = function(data,options) {

        chart.Bar.defaults = {
            scaleOverlay: false,
            scaleOverride: false,
            scaleSteps: null,
            scaleStepWidth: null,
            scaleStartValue: null,
            scaleLineColor: "rgba(0,0,0,.1)",
            scaleLineWidth: 1,
            scaleShowLabels: true,
            scaleLabel: "<%=value%>",
            scaleFontFamily: "'Arial'",
            scaleFontSize: 12,
            scaleFontStyle: "normal",
            scaleFontColor: "#666",
            scaleShowGridLines: true,
            scaleGridLineColor: "rgba(0,0,0,.05)",
            scaleGridLineWidth: 1,
            currentHourLine: false,
            barShowStroke: true,
            barStrokeWidth: 2,
            barValueSpacing: 5,
            barDatasetSpacing: 1,
            barOverlay: false,
            animation: true,
            animationSteps: 60,
            animationEasing: "easeOutQuart",
            onAnimationComplete: null,
            asOverview: false,

            fillColor: [],
            strokeColor: [],
        };

        var config = (options) ? mergeChartConfig(chart.Bar.defaults,options) : chart.Bar.defaults;

        return new Bar(data,config,context);
    }

// /////////////////////////////////////////////////////////////////
// Line implementation
// /////////////////////////////////////////////////////////////////

    var Line = function(data,config,ctx) {

        var maxSize;
        var scaleHop;
        var calculatedScale;
        var labelHeight;
        var scaleHeight;
        var valueBounds;
        var labelTemplateString;
        var valueHop;
        var widestXLabel;
        var xAxisLength;
        var yAxisLeftPosX;
        var yAxisRightPosX;
        var xAxisPosY;
        var longestText;
        var rotateLabels = 0;

        // /////////////////////////////////////////////////////////////////
        // initialisation
        // /////////////////////////////////////////////////////////////////

        this.init = function () {
            if (config.datasetFillDiff23 && data.datasets.length != 3) {
                config.datasetFillDiff23 = false;
            }

            calculateDrawingSizes();

            valueBounds = getValueBounds();
            labelTemplateString = (config.scaleShowLabels)? config.scaleLabel : "";

            if (config.asOverview) {
                config.scaleOverlay = false
                config.bezierCurve = true
                config.pointDot = false
                config.pointDotRadius = 0
                config.pointDotStrokeWidth = 0
                config.datasetFill = false
                config.currentHourLine = true
                config.datasetFillDiff23 = false
            }

            if (!config.scaleOverride) {
                calculatedScale = calculateScale(
                    scaleHeight,
                    valueBounds.maxSteps,
                    valueBounds.minSteps,
                    valueBounds.maxValue,
                    (config.scaleStartValue === null) ? valueBounds.minValue : config.scaleStartValue,
                    labelTemplateString
                );
            } else {
                calculatedScale = {
                    steps: config.scaleSteps,
                    stepValue: config.scaleStepWidth,
                    graphMin: config.scaleStartValue,
                    labels: []
                }
                populateLabels(labelTemplateString, calculatedScale.labels,calculatedScale.steps,config.scaleStartValue,config.scaleStepWidth);
            }

            scaleHop = Math.floor(scaleHeight/calculatedScale.steps);
            calculateXAxisSize();
        }

        // /////////////////////////////////////////////////////////////////
        // drawing
        // /////////////////////////////////////////////////////////////////

        this.draw = function (progress) {

            this.init();

            clear(ctx);

            if(config.scaleOverlay) {
                drawScale();
            } else {
                drawScale();
                drawLines(progress);
            }
        }

        // ///////////////////////////////////////////////////////////////

        function drawLines(animPc) {

            for (var i=0; i<data.datasets.length; i++) {
                ctx.strokeStyle = (config.strokeColor[i] ? config.strokeColor[i] : data.datasets[i].strokeColor);
                ctx.lineWidth = config.datasetStrokeWidth;
                ctx.beginPath();
                ctx.moveTo(xPos(0), yPos(i, 0))

                for (var j=1; j<data.datasets[i].data.length; j++) {
                    if (config.bezierCurve) {
                        ctx.bezierCurveTo(xPos(j-0.5),yPos(i,j-1),xPos(j-0.5),yPos(i,j),xPos(j),yPos(i,j));
                    } else{
                        ctx.lineTo(xPos(j),yPos(i,j));
                    }
                }

                ctx.stroke();

                if (config.datasetFill && (i == 0 || !config.datasetFillDiff23)) {
                    ctx.lineTo(xPos(data.datasets[i].data.length-1),xAxisPosY);
                    ctx.lineTo(xPos(0),xAxisPosY);
                    ctx.closePath();
                    ctx.fillStyle = (config.fillColor[i] ? config.fillColor[i] : data.datasets[i].fillColor);
                    ctx.fill();
                } else if (i == 2 && config.datasetFillDiff23) {
                    for (var k=data.datasets[1].data.length; k>=0; k--) {
                        ctx.lineTo(xPos(k),yPos(1,k));
                    }

                    ctx.closePath();
                    ctx.fillStyle = (config.fillColor[i] ? config.fillColor[i] : data.datasets[i].fillColor);
                    ctx.fill();
                }else {
                    ctx.closePath();
                }

                if (config.pointDot && (i == 0 || !config.datasetFillDiff23)) {
                    ctx.fillStyle = (config.pointColor[i] ? config.pointColor[i] : data.datasets[i].pointColor);
                    ctx.strokeStyle = (config.pointStrokeColor[i] ? config.pointStrokeColor[i] : data.datasets[i].pointStrokeColor);
                    ctx.lineWidth = config.pointDotStrokeWidth;
                    for (var k=0; k<data.datasets[i].data.length; k++) {
                        ctx.beginPath();
                        ctx.arc(xPos(k),yPos(i, k),config.pointDotRadius,0,Math.PI*2,true);
                        ctx.fill();
                        ctx.stroke();
                    }
                }

                if (config.asOverview) break;
            }

            function yPos(dataSet,iteration) {
                return xAxisPosY - animPc*(calculateOffset(data.datasets[dataSet].data[iteration],calculatedScale,scaleHop));
            }

            function xPos(iteration) {
                return yAxisLeftPosX + (valueHop * iteration) + valueHop/2;
            }
        }

        function drawScale() {

            ctx.lineWidth = config.scaleLineWidth;
            ctx.strokeStyle = config.scaleLineColor;

            if (!config.scaleOverlay) {
                ctx.beginPath();

                if (config.asOverview) {
                    ctx.moveTo(width-widestXLabel/2+5-longestText,xAxisPosY);
                    ctx.lineTo(width-(widestXLabel/2)-xAxisLength-5-longestText,xAxisPosY);
                } else {
                    ctx.moveTo(width-widestXLabel/2+5,xAxisPosY);
                    ctx.lineTo(width-(widestXLabel/2)-xAxisLength-5,xAxisPosY);
                }

                ctx.stroke();
            }

            if (config.currentHourLine && !config.scaleOverlay) {
                var now = new Date();
                var hour = now.getHours();
                hour += now.getMinutes()/60;

                ctx.beginPath();
                ctx.moveTo(yAxisLeftPosX + hour*valueHop + valueHop/2,xAxisPosY);
                ctx.lineTo(yAxisLeftPosX + hour*valueHop + valueHop/2,5);
                ctx.stroke();
            }

            if (rotateLabels > 0) {
                ctx.save();
                ctx.textAlign = "right";
            } else{
                ctx.textAlign = "center";
            }
            ctx.fillStyle = config.scaleFontColor;

            if (!config.scaleOverlay) {
                for (var i=0; i<data.labels.length; i++) {
                    if (config.asOverview && (i+1)%2 != 0) continue;

                    ctx.save();

                    if (rotateLabels > 0) {
                        ctx.translate(yAxisLeftPosX + i*valueHop,xAxisPosY + config.scaleFontSize);
                        ctx.rotate(-(rotateLabels * (Math.PI/180)));
                        ctx.fillText(data.labels[i], 0,0);
                        ctx.restore();
                    } else {
                        ctx.fillText(data.labels[i], yAxisLeftPosX + i*valueHop + valueHop/2,xAxisPosY + config.scaleFontSize+3);
                    }

                    ctx.beginPath();
                    ctx.moveTo(yAxisLeftPosX + i * valueHop, xAxisPosY+3);

                    if(config.scaleShowGridLines && i>0) {
                        ctx.lineWidth = config.scaleGridLineWidth;
                        ctx.strokeStyle = config.scaleGridLineColor;
                        ctx.lineTo(yAxisLeftPosX + i * valueHop, 5);
                    } else{
                        ctx.lineTo(yAxisLeftPosX + i * valueHop, xAxisPosY+3);
                    }
                    ctx.stroke();
                }
            }

            ctx.lineWidth = config.scaleLineWidth;
            ctx.strokeStyle = config.scaleLineColor;
            ctx.beginPath();
            ctx.moveTo(yAxisLeftPosX,xAxisPosY+5);
            ctx.lineTo(yAxisLeftPosX,5);
            ctx.stroke();
            ctx.textAlign = "right";
            ctx.textBaseline = "middle";

            for (var j=0; j<calculatedScale.steps; j++) {
                ctx.beginPath();
                ctx.moveTo(yAxisLeftPosX-3,xAxisPosY - ((j+1) * scaleHop));
                if (config.scaleShowGridLines) {
                    ctx.lineWidth = config.scaleGridLineWidth;
                    ctx.strokeStyle = config.scaleGridLineColor;
                    ctx.lineTo(yAxisLeftPosX + xAxisLength + 5,xAxisPosY - ((j+1) * scaleHop));
                } else {
                    ctx.lineTo(yAxisLeftPosX-0.5,xAxisPosY - ((j+1) * scaleHop));
                }
                ctx.stroke();
                if (config.scaleShowLabels) {
                    ctx.fillText(calculatedScale.labels[j],yAxisLeftPosX-8,xAxisPosY - ((j+1) * scaleHop));
                }
            }

            if (config.asOverview) {
                ctx.lineWidth = config.scaleLineWidth*2;
                ctx.strokeStyle = config.strokeColor[0];
                ctx.beginPath();
                ctx.moveTo(yAxisLeftPosX,xAxisPosY+5);
                ctx.lineTo(yAxisLeftPosX,5);
                ctx.stroke();
            }
        }

        function calculateXAxisSize() {
            longestText = 1;

            if (config.scaleShowLabels) {
                ctx.font = config.scaleFontStyle + " " + config.scaleFontSize+"px " + config.scaleFontFamily;
                longestText = ctx.measureText("9.99").width + 10;
            }

            if (config.asOverview) {
                xAxisLength = width - 2*longestText - widestXLabel;
            } else {
                xAxisLength = width - longestText - widestXLabel;
            }

            valueHop = Math.floor(xAxisLength/(data.labels.length));

            if (config.asOverview) {
                yAxisLeftPosX = width-widestXLabel/2-xAxisLength-longestText;
                yAxisRightPosX = width-widestXLabel/2-longestText;
            } else {
                yAxisLeftPosX = width-widestXLabel/2-xAxisLength;
                yAxisRightPosX = undefined
            }

            xAxisPosY = scaleHeight + config.scaleFontSize/2;
        }

        function calculateDrawingSizes() {

            maxSize = height;

            ctx.font = config.scaleFontStyle + " " + config.scaleFontSize+"px " + config.scaleFontFamily;

            widestXLabel = 1;

            for (var i=0; i<data.labels.length; i++) {
                if (config.asOverview && (i+1)%2 != 0) continue;
                var textLength = ctx.measureText(data.labels[i]).width;
                widestXLabel = (textLength > widestXLabel)? textLength : widestXLabel;
            }

            if (!config.scaleOverlay && width/data.labels.length < widestXLabel) {

                rotateLabels = 45;

                if (width/data.labels.length < Math.cos(rotateLabels) * widestXLabel) {
                    rotateLabels = 90;
                    maxSize -= widestXLabel;
                } else{
                    maxSize -= Math.sin(rotateLabels) * widestXLabel;
                }
            } else{
                maxSize -= config.scaleFontSize;
            }

            maxSize -= 5;

            labelHeight = config.scaleFontSize;

            maxSize -= labelHeight;

            scaleHeight = maxSize;
        }

        function getValueBounds() {

            var upperValue = Number.MIN_VALUE;
            var lowerValue = Number.MAX_VALUE;

            if (config.asOverview) {
                upperValue = Math.max.apply(Math, data.datasets[0].data);
                lowerValue = Math.min.apply(Math, data.datasets[0].data);
            } else {
                for (var i=0; i<data.datasets.length; i++) {
                    var u = Math.max.apply(Math, data.datasets[i].data);
                    var l = Math.min.apply(Math, data.datasets[i].data);

                    if ( u > upperValue) { upperValue = u; };
                    if ( l < lowerValue) { lowerValue = l; };
                };
            }

            var maxSteps = Math.floor((scaleHeight / (labelHeight*0.66)));
            var minSteps = Math.floor((scaleHeight / labelHeight*0.5));

            return {
                maxValue: upperValue,
                minValue: lowerValue,
                maxSteps: maxSteps,
                minSteps: minSteps
            };
        }
    }

// /////////////////////////////////////////////////////////////////
// Bar implementation
// /////////////////////////////////////////////////////////////////

    var Bar = function(data, config, ctx) {

        var maxSize;
        var scaleHop;
        var calculatedScale;
        var labelHeight;
        var scaleHeight;
        var valueBounds;
        var labelTemplateString;
        var valueHop;
        var widestXLabel;
        var xAxisLength;
        var yAxisLeftPosX;
        var yAxisRightPosX;
        var xAxisPosY;
        var barWidth;
        var longestText;
        var rotateLabels = 0;

        // /////////////////////////////////////////////////////////////////
        // initialisation
        // /////////////////////////////////////////////////////////////////

        this.init = function () {

            calculateDrawingSizes();

            valueBounds = getValueBounds();

            labelTemplateString = (config.scaleShowLabels)? config.scaleLabel : "";

            if (!config.scaleOverride) {
                calculatedScale = calculateScale(scaleHeight,valueBounds.maxSteps,valueBounds.minSteps,valueBounds.maxValue,valueBounds.minValue,labelTemplateString);
            } else {
                calculatedScale = {
                    steps: config.scaleSteps,
                    stepValue: config.scaleStepWidth,
                    graphMin: config.scaleStartValue,
                    labels: []
                }
                populateLabels(labelTemplateString, calculatedScale.labels,calculatedScale.steps,config.scaleStartValue,config.scaleStepWidth);
            }

            scaleHop = Math.floor(scaleHeight/calculatedScale.steps);
            calculateXAxisSize();
        }

        // /////////////////////////////////////////////////////////////////
        // drawing
        // /////////////////////////////////////////////////////////////////

        this.draw = function (progress) {

            clear(ctx);

            if(config.scaleOverlay) {
                drawScale();
            } else {
                drawScale();
                drawBars(progress);
            }
        }

        // ///////////////////////////////////////////////////////////////

        function drawBars(animPc) {

            ctx.lineWidth = config.barStrokeWidth;

            for (var i=0; i<data.datasets.length; i++) {
                ctx.fillStyle = (config.fillColor[i] ? config.fillColor[i] : data.datasets[i].fillColor);
                ctx.strokeStyle = (config.strokeColor[i] ? config.strokeColor[i] : data.datasets[i].strokeColor);

                for (var j=0; j<data.datasets[i].data.length; j++) {

                    if (config.barOverlay) {
                        var barOffset = yAxisLeftPosX + config.barValueSpacing + valueHop*j + config.barStrokeWidth;
                    } else {
                        var barOffset = yAxisLeftPosX + config.barValueSpacing + valueHop*j + barWidth*i + config.barDatasetSpacing*i + config.barStrokeWidth*i;
                    }

                    ctx.beginPath();
                    ctx.moveTo(barOffset, xAxisPosY);
                    ctx.lineTo(barOffset, xAxisPosY - animPc*calculateOffset(data.datasets[i].data[j],calculatedScale,scaleHop)+(config.barStrokeWidth/2));
                    ctx.lineTo(barOffset + barWidth, xAxisPosY - animPc*calculateOffset(data.datasets[i].data[j],calculatedScale,scaleHop)+(config.barStrokeWidth/2));
                    ctx.lineTo(barOffset + barWidth, xAxisPosY);
                    if(config.barShowStroke) {
                        ctx.stroke();
                    }
                    ctx.closePath();
                    ctx.fill();
                }
            }
        }

        function drawScale() {

            ctx.lineWidth = config.scaleLineWidth;
            ctx.strokeStyle = config.scaleLineColor;

            if (!config.scaleOverlay) {
                ctx.beginPath();

                if (config.asOverview) {
                    ctx.moveTo(width-widestXLabel/2+5-longestText,xAxisPosY);
                    ctx.lineTo(width-(widestXLabel/2)-xAxisLength-5-longestText,xAxisPosY);
                } else {
                    ctx.moveTo(width-widestXLabel/2+5,xAxisPosY);
                    ctx.lineTo(width-(widestXLabel/2)-xAxisLength-5,xAxisPosY);
                }
                ctx.stroke();
            }

            if (config.currentHourLine && !config.scaleOverlay) {
                var now = new Date();
                var hour = now.getHours();
                hour += now.getMinutes()/60;

                ctx.beginPath();
                ctx.moveTo(yAxisLeftPosX + hour*valueHop + valueHop/2, xAxisPosY);
                ctx.lineTo(yAxisLeftPosX + hour*valueHop + valueHop/2, 5);
                ctx.stroke();
            }

            if (rotateLabels > 0) {
                ctx.save();
                ctx.textAlign = "right";
            } else{
                ctx.textAlign = "center";
            }

            ctx.fillStyle = config.scaleFontColor;

            if (!config.scaleOverlay && !config.asOverview) {
                for (var i=0; i<data.labels.length; i++) {
                    ctx.save();
                    if (rotateLabels > 0) {
                        ctx.translate(yAxisLeftPosX + i*valueHop,xAxisPosY + config.scaleFontSize);
                        ctx.rotate(-(rotateLabels * (Math.PI/180)));
                        ctx.fillText(data.labels[i], 0,0);
                        ctx.restore();
                    } else {
                        ctx.fillText(data.labels[i], yAxisLeftPosX + i*valueHop + valueHop/2,xAxisPosY + config.scaleFontSize+3);
                    }

                    ctx.beginPath();
                    ctx.moveTo(yAxisLeftPosX + (i+1) * valueHop, xAxisPosY+3);
                    ctx.lineWidth = config.scaleGridLineWidth;
                    ctx.strokeStyle = config.scaleGridLineColor;
                    ctx.lineTo(yAxisLeftPosX + (i+1) * valueHop, 5);
                    ctx.stroke();
                }
            }

            ctx.beginPath();

            if (config.asOverview) {
                ctx.lineWidth = config.scaleLineWidth*2;
                ctx.strokeStyle = config.strokeColor[0] === "rgba(0,0,0,0)" ? config.scaleLineColor : config.strokeColor[0];
                ctx.moveTo(yAxisRightPosX,xAxisPosY+5);
                ctx.lineTo(yAxisRightPosX,5);
            } else {
                ctx.lineWidth = config.scaleLineWidth;
                ctx.strokeStyle = config.scaleLineColor;
                ctx.moveTo(yAxisLeftPosX,xAxisPosY+5);
                ctx.lineTo(yAxisLeftPosX,5);
            }

            ctx.stroke();
            ctx.lineWidth = config.scaleLineWidth;
            ctx.strokeStyle = config.scaleLineColor;
            ctx.textBaseline = "middle";

            if (config.asOverview) {
                ctx.textAlign = "left";
                for (var j=0; j<calculatedScale.steps; j++) {
                    ctx.beginPath();
                    ctx.moveTo(yAxisRightPosX-3,xAxisPosY - ((j+1) * scaleHop));
                    if (config.scaleShowGridLines) {
                        ctx.lineWidth = config.scaleGridLineWidth;
                        ctx.strokeStyle = config.scaleGridLineColor;
                        ctx.lineTo(yAxisRightPosX + xAxisLength + 5,xAxisPosY - ((j+1) * scaleHop));
                    } else {
                        ctx.lineTo(yAxisRightPosX-0.5,xAxisPosY - ((j+1) * scaleHop));
                    }
                    ctx.stroke();
                    if (config.scaleShowLabels) {
                        ctx.fillText(calculatedScale.labels[j],yAxisRightPosX+8,xAxisPosY - ((j+1) * scaleHop));
                    }
                }
            } else {
                ctx.textAlign = "right";
                for (var j=0; j<calculatedScale.steps; j++) {
                    ctx.beginPath();
                    ctx.moveTo(yAxisLeftPosX-3,xAxisPosY - ((j+1) * scaleHop));
                    if (config.scaleShowGridLines) {
                        ctx.lineWidth = config.scaleGridLineWidth;
                        ctx.strokeStyle = config.scaleGridLineColor;
                        ctx.lineTo(yAxisLeftPosX + xAxisLength + 5,xAxisPosY - ((j+1) * scaleHop));
                    } else {
                        ctx.lineTo(yAxisLeftPosX-0.5,xAxisPosY - ((j+1) * scaleHop));
                    }
                    ctx.stroke();
                    if (config.scaleShowLabels) {
                        ctx.fillText(calculatedScale.labels[j],yAxisLeftPosX-8,xAxisPosY - ((j+1) * scaleHop));
                    }
                }
            }
        }

        function calculateXAxisSize() {
            longestText = 1;

            if (config.scaleShowLabels) {
                ctx.font = config.scaleFontStyle + " " + config.scaleFontSize+"px " + config.scaleFontFamily;
                longestText = ctx.measureText("9.99").width + 10;
            }

            if (config.asOverview) {
                xAxisLength = width - 2*longestText - widestXLabel;
            } else {
                xAxisLength = width - longestText - widestXLabel;
            }
            valueHop = Math.floor(xAxisLength/(data.labels.length));

            if (config.barOverlay) {
                barWidth = (valueHop - config.scaleGridLineWidth*2 - (config.barValueSpacing*2));
            } else {
                barWidth = (valueHop - config.scaleGridLineWidth*2 - (config.barValueSpacing*2) - (config.barDatasetSpacing*data.datasets.length-1) - ((config.barStrokeWidth/2)*data.datasets.length-1))/data.datasets.length;
            }

            if (config.asOverview) {
                yAxisLeftPosX = width-widestXLabel/2-xAxisLength-longestText;
                yAxisRightPosX = width-widestXLabel/2-longestText;
            } else {
                yAxisLeftPosX = width-widestXLabel/2-xAxisLength;
                yAxisRightPosX = undefined
            }
            xAxisPosY = scaleHeight + config.scaleFontSize/2;
        }

        function calculateDrawingSizes() {

            maxSize = height;
            ctx.font = config.scaleFontStyle + " " + config.scaleFontSize+"px " + config.scaleFontFamily;
            widestXLabel = 1;

            for (var i=0; i<data.labels.length; i++) {
                var textLength = ctx.measureText(data.labels[i]).width;
                widestXLabel = (textLength > widestXLabel)? textLength : widestXLabel;
            }

            if (!config.scaleOverlay && width/data.labels.length < widestXLabel) {
                rotateLabels = 45;
                if (width/data.labels.length < Math.cos(rotateLabels) * widestXLabel) {
                    rotateLabels = 90;
                    maxSize -= widestXLabel;
                } else{
                    maxSize -= Math.sin(rotateLabels) * widestXLabel;
                }
            } else{
                maxSize -= config.scaleFontSize;
            }

            maxSize -= 5;

            labelHeight = config.scaleFontSize;

            maxSize -= labelHeight;

            scaleHeight = maxSize;
        }

        function getValueBounds() {
            var upperValue = Number.MIN_VALUE;
            var lowerValue = Number.MAX_VALUE;

            for (var i=0; i<data.datasets.length; i++) {
                var u = Math.max.apply(Math, data.datasets[i].data);
                var l = Math.min.apply(Math, data.datasets[i].data);

                if ( u > upperValue) { upperValue = u; };
                if ( l < lowerValue) { lowerValue = l; };
            };

            var maxSteps = Math.floor((scaleHeight / (labelHeight*0.66)));
            var minSteps = Math.floor((scaleHeight / labelHeight*0.5));

            return {
                maxValue: upperValue,
                minValue: lowerValue,
                maxSteps: maxSteps,
                minSteps: minSteps
            };
        }
    }

// /////////////////////////////////////////////////////////////////
// Helper functions
// /////////////////////////////////////////////////////////////////

    var clear = function(c) {
        c.clearRect(0, 0, width, height);
    };


    function calculateOffset(val,calculatedScale,scaleHop) {

        var outerValue = calculatedScale.steps * calculatedScale.stepValue;
        var adjustedValue = val - calculatedScale.graphMin;
        var scalingFactor = CapValue(adjustedValue/outerValue,1,0);

        return (scaleHop*calculatedScale.steps) * scalingFactor;
    }

    function calculateScale(drawingHeight,maxSteps,minSteps,maxValue,minValue,labelTemplateString) {

        var graphMin,graphMax,graphRange,stepValue,numberOfSteps,valueRange,rangeOrderOfMagnitude,decimalNum;

        valueRange = maxValue - minValue;
        rangeOrderOfMagnitude = calculateOrderOfMagnitude(valueRange);
        graphMin = Math.floor(minValue / (1 * Math.pow(10, rangeOrderOfMagnitude))) * Math.pow(10, rangeOrderOfMagnitude);
        graphMax = Math.ceil(maxValue / (1 * Math.pow(10, rangeOrderOfMagnitude))) * Math.pow(10, rangeOrderOfMagnitude);
        graphRange = graphMax - graphMin;
        stepValue = Math.pow(10, rangeOrderOfMagnitude);
        numberOfSteps = Math.round(graphRange / stepValue);

        while(numberOfSteps < minSteps || numberOfSteps > maxSteps) {
            if (numberOfSteps < minSteps) {
                stepValue /= 2;
                numberOfSteps = Math.round(graphRange/stepValue);
            } else{
                stepValue *=2;
                numberOfSteps = Math.round(graphRange/stepValue);
            }
        };

        var labels = [];

        populateLabels(labelTemplateString, labels, numberOfSteps, graphMin, stepValue);

        return {
            steps: numberOfSteps,
            stepValue: stepValue,
            graphMin: graphMin,
            labels: labels
        }

        function calculateOrderOfMagnitude(val) {
            return Math.floor(Math.log(val) / Math.LN10);
        }
    }

    function populateLabels(labelTemplateString, labels, numberOfSteps, graphMin, stepValue) {
        if (labelTemplateString) {
            for (var i = 1; i < numberOfSteps + 1; i++) {
                labels.push(tmpl(labelTemplateString, {value: (graphMin + (stepValue * i)).toFixed(getDecimalPlaces(stepValue))}));
            }
        }
    }

    function Max(array) {
        return Math.max.apply(Math, array);
    };

    function Min(array) {
        return Math.min.apply(Math, array);
    };

    function Default(userDeclared,valueIfFalse) {
        if(!userDeclared) {
            return valueIfFalse;
        } else {
            return userDeclared;
        }
    };

    function isNumber(n) {
        return !isNaN(parseFloat(n)) && isFinite(n);
    }

    function CapValue(valueToCap, maxValue, minValue) {
        if(isNumber(maxValue)) {
            if( valueToCap > maxValue ) {
                return maxValue;
            }
        }
        if(isNumber(minValue)) {
            if ( valueToCap < minValue ) {
                return minValue;
            }
        }
        return valueToCap;
    }

    function getDecimalPlaces (num) {
        var numberOfDecimalPlaces;
        if (num%1!=0) {
            return num.toString().split(".")[1].length
        } else {
            return 0;
        }
    }

    function mergeChartConfig(defaults,userDefined) {
        var returnObj = {};
        for (var attrname in defaults) { returnObj[attrname] = defaults[attrname]; }
        for (var attrname in userDefined) { returnObj[attrname] = userDefined[attrname]; }
        return returnObj;
    }

    var cache = {};

    function tmpl(str, data) {
        var fn = !/\W/.test(str) ?
            cache[str] = cache[str] ||
            tmpl(document.getElementById(str).innerHTML) :

        new Function("obj",
                     "var p=[],print=function() {p.push.apply(p,arguments);};" +
                     "with(obj) {p.push('" +
                     str
                     .replace(/[\r\t\n]/g, " ")
                     .split("<%").join("\t")
                     .replace(/((^|%>)[^\t]*)'/g, "$1\r")
                     .replace(/\t=(.*?)%>/g, "',$1,'")
                     .split("\t").join("');")
                     .split("%>").join("p.push('")
                     .split("\r").join("\\'")
                     + "');}return p.join('');");

        return data ? fn( data ) : fn;
    };
}

// /////////////////////////////////////////////////////////////////
// Credits
// /////////////////////////////////////////////////////////////////

/*!
 * Chart.js
 * http://chartjs.org/
 *
 * Copyright 2013 Nick Downie
 * Released under the MIT license
 * https://github.com/nnnick/Chart.js/blob/master/LICENSE.md
 */

// Copyright (c) 2013 Nick Downie

// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
