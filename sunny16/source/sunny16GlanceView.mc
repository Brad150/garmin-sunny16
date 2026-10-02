import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

(:glance)
class sunny16GlanceView extends WatchUi.GlanceView {

    function initialize() {
        GlanceView.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        var height = dc.getHeight();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        dc.drawText(
            0,
            0,
            Graphics.FONT_TINY,
            WatchUi.loadResource(Rez.Strings.AppName) as String,
            Graphics.TEXT_JUSTIFY_LEFT
        );

        dc.drawText(
            0,
            height / 2,
            Graphics.FONT_SMALL,
            Sunny16State.exposureLabel(),
            Graphics.TEXT_JUSTIFY_LEFT
        );

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(
            0,
            height - dc.getFontHeight(Graphics.FONT_XTINY),
            Graphics.FONT_XTINY,
            Sunny16State.isoLabel() + "  " + Sunny16State.conditionName(),
            Graphics.TEXT_JUSTIFY_LEFT
        );
    }
}
