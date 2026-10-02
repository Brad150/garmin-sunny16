import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class sunny16View extends WatchUi.View {
    hidden var _interactive as Boolean;

    function initialize(interactive as Boolean) {
        View.initialize();
        _interactive = interactive;
    }

    function onUpdate(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var cx = width / 2;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

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
            Graphics.FONT_LARGE,
            Sunny16State.exposureLabel(),
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawText(
            cx,
            height * 70 / 100,
            Graphics.FONT_MEDIUM,
            Sunny16State.isoLabel(),
            Graphics.TEXT_JUSTIFY_CENTER
        );

        var hint = WatchUi.loadResource(Rez.Strings.HintOpen) as String;
        if (_interactive) {
            hint = WatchUi.loadResource(Rez.Strings.HintControls) as String;
        }

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(
            cx,
            height * 86 / 100,
            Graphics.FONT_XTINY,
            hint,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }
}
