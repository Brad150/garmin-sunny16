import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

module Sunny16Step {
    const SUMMARY as Number = 0;
    const ISO as Number = 1;
    const LIGHT as Number = 2;
    const SCALE as Number = 3;
}

class sunny16View extends WatchUi.View {
    var step as Number;
    hidden var _interactive as Boolean;

    function initialize(interactive as Boolean) {
        View.initialize();
        _interactive = interactive;
        if (_interactive) {
            step = Sunny16Step.ISO;
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
            height * 16 / 100,
            Graphics.FONT_TINY,
            WatchUi.loadResource(Rez.Strings.StepLight) as String,
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
        var headerFont = Graphics.FONT_XTINY;
        var headerY = height * 14 / 100;
        var rowFont = Graphics.FONT_SMALL;
        var rowH = dc.getFontHeight(rowFont);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(
            cx,
            headerY,
            headerFont,
            Sunny16State.conditionName() + "  " + Sunny16State.isoLabel(),
            Graphics.TEXT_JUSTIFY_CENTER
        );

        var listTop = headerY + dc.getFontHeight(headerFont) + (height * 3 / 100);
        var listBottom = height * 90 / 100;
        var available = listBottom - listTop;
        var rows = 1;
        if (rowH > 0) {
            rows = available / rowH;
        }
        if (rows > 5) {
            rows = 5;
        }
        if ((rows % 2) == 0) {
            rows = rows - 1;
        }
        if (rows < 1) {
            rows = 1;
        }

        var blockH = rows * rowH;
        var top = listTop + ((available - blockH) / 2);
        var mid = rows / 2;
        var selectedTop = top + (mid * rowH);
        var barW = width * 72 / 100;
        var barX = (width - barW) / 2;

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.fillRectangle(barX, selectedTop, barW, rowH);

        var minOff = Sunny16State.minStopOffset();
        var maxOff = Sunny16State.maxStopOffset();
        var apertureX = width * 50 / 100;
        var shutterX = width * 56 / 100;
        var radius = rowH / 8;
        if (radius < 2) {
            radius = 2;
        }
        var markerX = barX + radius + 3;
        var offset = 0;
        var rowTop = 0;
        var textY = 0;
        var fontH = dc.getFontHeight(rowFont);

        var i = 0;
        for (i = 0; i < rows; i += 1) {
            offset = Sunny16State.stopOffset + (mid - i);
            if ((offset < minOff) || (offset > maxOff)) {
                continue;
            }

            rowTop = top + (i * rowH);
            textY = rowTop + ((rowH - fontH) / 2);
            if (offset == 0) {
                dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(markerX, rowTop + (rowH / 2), radius);
            }

            if (i == mid) {
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
}
