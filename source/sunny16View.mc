import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.WatchUi;

module Sunny16Step {
    const SUMMARY as Number = 0;
    const ISO as Number = 1;
    const LIGHT as Number = 2;
    const SCALE as Number = 3;
}

class sunny16View extends WatchUi.View {
    var step as Number;
    var isoReturn as Number;
    hidden var _interactive as Boolean;

    function initialize(interactive as Boolean) {
        View.initialize();
        _interactive = interactive;
        isoReturn = Sunny16Step.LIGHT;
        if (_interactive) {
            step = Sunny16Step.LIGHT;
        } else {
            step = Sunny16Step.SUMMARY;
        }
    }

    function isInteractive() as Boolean {
        return _interactive;
    }

    function onUpdate(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        if (step == Sunny16Step.ISO) {
            drawIso(dc, width, height);
        } else if (step == Sunny16Step.LIGHT) {
            drawLight(dc, width, height);
        } else if (step == Sunny16Step.SCALE) {
            drawScale(dc, width, height);
        } else {
            drawSummary(dc, width, height);
        }
    }

    hidden function drawSummary(dc as Dc, width as Number, height as Number) as Void {
        var cx = width / 2;

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(
            cx,
            height * 12 / 100,
            Graphics.FONT_TINY,
            WatchUi.loadResource(Rez.Strings.AppName) as String,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(
            cx,
            height * 30 / 100,
            Graphics.FONT_SMALL,
            Sunny16State.conditionName(),
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawText(
            cx,
            height * 48 / 100,
            Graphics.FONT_MEDIUM,
            Sunny16State.selectedPairLabel(),
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawText(
            cx,
            height * 70 / 100,
            Graphics.FONT_MEDIUM,
            Sunny16State.isoLabel(),
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(
            cx,
            height * 86 / 100,
            Graphics.FONT_XTINY,
            WatchUi.loadResource(Rez.Strings.HintOpen) as String,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    hidden function drawIso(dc as Dc, width as Number, height as Number) as Void {
        var cx = width / 2;

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(
            cx,
            height * 18 / 100,
            Graphics.FONT_TINY,
            WatchUi.loadResource(Rez.Strings.StepIso) as String,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(
            cx,
            height * 38 / 100,
            Graphics.FONT_LARGE,
            Sunny16State.isoValue().toString(),
            Graphics.TEXT_JUSTIFY_CENTER
        );

        drawHint(dc, cx, height, WatchUi.loadResource(Rez.Strings.HintIso) as String);
    }

    hidden function drawLight(dc as Dc, width as Number, height as Number) as Void {
        var cx = width / 2;

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(
            cx,
            height * 14 / 100,
            Graphics.FONT_TINY,
            Sunny16State.isoLabel(),
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(
            cx,
            height * 34 / 100,
            Graphics.FONT_MEDIUM,
            Sunny16State.conditionName(),
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawText(
            cx,
            height * 54 / 100,
            Graphics.FONT_SMALL,
            Sunny16State.basePairLabel(),
            Graphics.TEXT_JUSTIFY_CENTER
        );

        drawHint(dc, cx, height, WatchUi.loadResource(Rez.Strings.HintLight) as String);
    }

    hidden function drawHint(dc as Dc, cx as Number, height as Number, hint as String) as Void {
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(
            cx,
            height * 80 / 100,
            Graphics.FONT_XTINY,
            hint,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    hidden function drawScale(dc as Dc, width as Number, height as Number) as Void {
        var cx = width / 2;
        var centerY = height / 2;
        var radius = width / 2;
        var headerFont = Graphics.FONT_XTINY;
        var rowFont = Graphics.FONT_TINY;
        var header = Sunny16State.conditionName() + "  " + Sunny16State.isoLabel();
        var headerH = dc.getFontHeight(headerFont);
        var headerW = dc.getTextWidthInPixels(header, headerFont);
        var rowH = dc.getFontHeight(rowFont);
        var fontH = rowH;
        var gap = height / 100;
        var barW = width * 60 / 100;
        var headerTop = 0;
        var listTop = 0;
        var listBottom = 0;
        var barLimit = 0;
        var available = 0;
        var rows = 1;
        var minOff = 0;
        var maxOff = 0;
        var validCount = 0;
        var selectedPos = 0;
        var windowTop = 0;
        var selectedRow = 0;
        var blockH = 0;
        var top = 0;
        var barX = 0;
        var selectedTop = 0;
        var apertureX = width * 50 / 100;
        var shutterX = width * 56 / 100;
        var markerRadius = 0;
        var markerX = 0;
        var offset = 0;
        var rowTop = 0;
        var textY = 0;
        var i = 0;

        if ((height / 2) < radius) {
            radius = height / 2;
        }
        if (gap < 1) {
            gap = 1;
        }

        headerTop = centerY - fitRadius(radius, (headerW / 2) + 4);
        if (headerTop < 0) {
            headerTop = 0;
        }

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(
            cx,
            headerTop,
            headerFont,
            header,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        minOff = Sunny16State.minStopOffset();
        maxOff = Sunny16State.maxStopOffset();
        validCount = (maxOff - minOff) + 1;
        if (validCount < 1) {
            validCount = 1;
            maxOff = minOff;
        }

        barLimit = fitRadius(radius, (barW / 2) + 2);
        listTop = headerTop + headerH + gap;
        if (listTop < (centerY - barLimit)) {
            listTop = centerY - barLimit;
        }
        listBottom = centerY + barLimit;
        if (listBottom > height) {
            listBottom = height;
        }
        available = listBottom - listTop;
        if ((rowH > 0) && (available > rowH)) {
            rows = available / rowH;
        }
        if (rows > validCount) {
            rows = validCount;
        }
        if (rows < 1) {
            rows = 1;
        }

        selectedPos = maxOff - Sunny16State.stopOffset;
        if (selectedPos < 0) {
            selectedPos = 0;
        }
        if (selectedPos >= validCount) {
            selectedPos = validCount - 1;
        }

        windowTop = 0;
        selectedRow = selectedPos;
        if (validCount > rows) {
            windowTop = selectedPos - (rows / 2);
            if (windowTop < 0) {
                windowTop = 0;
            }
            if (windowTop > (validCount - rows)) {
                windowTop = validCount - rows;
            }
            selectedRow = selectedPos - windowTop;
        }

        blockH = rows * rowH;
        top = listTop;
        if (available > blockH) {
            top = listTop + ((available - blockH) / 2);
        }

        barX = (width - barW) / 2;
        selectedTop = top + (selectedRow * rowH);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.fillRectangle(barX, selectedTop, barW, rowH);

        markerRadius = rowH / 8;
        if (markerRadius < 2) {
            markerRadius = 2;
        }
        markerX = barX + markerRadius + 3;

        for (i = 0; i < rows; i += 1) {
            offset = maxOff - (windowTop + i);
            rowTop = top + (i * rowH);
            textY = rowTop + ((rowH - fontH) / 2);
            if (offset == 0) {
                dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(markerX, rowTop + (rowH / 2), markerRadius);
            }

            if (i == selectedRow) {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_DK_GRAY);
            } else {
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
            }

            dc.drawText(
                apertureX,
                textY,
                rowFont,
                Sunny16State.apertureLabelForOffset(offset),
                Graphics.TEXT_JUSTIFY_RIGHT
            );
            dc.drawText(
                shutterX,
                textY,
                rowFont,
                Sunny16State.shutterLabelForOffset(offset),
                Graphics.TEXT_JUSTIFY_LEFT
            );
        }
    }

    // Distance from screen center where a centered span of halfWidth still fits the circle.
    hidden function fitRadius(radius as Number, halfWidth as Number) as Number {
        var inside = 0;
        var root = 0.0;
        if (halfWidth < 1) {
            return radius;
        }
        if (halfWidth >= radius) {
            return 0;
        }
        inside = (radius * radius) - (halfWidth * halfWidth);
        root = Math.sqrt(inside);
        return root.toNumber();
    }
}
