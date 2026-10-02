import Toybox.Lang;
import Toybox.WatchUi;

class sunny16Delegate extends WatchUi.BehaviorDelegate {
    hidden var _interactive as Boolean;

    function initialize(interactive as Boolean) {
        BehaviorDelegate.initialize();
        _interactive = interactive;
    }

    function onSelect() as Boolean {
        if (!_interactive) {
            WatchUi.pushView(new sunny16View(true), new sunny16Delegate(true), WatchUi.SLIDE_LEFT);
            return true;
        }

        Sunny16State.nextIso();
        WatchUi.requestUpdate();
        return true;
    }

    function onNextPage() as Boolean {
        if (!_interactive) {
            return false;
        }

        Sunny16State.nextCondition();
        WatchUi.requestUpdate();
        return true;
    }

    function onPreviousPage() as Boolean {
        if (!_interactive) {
            return false;
        }

        Sunny16State.previousCondition();
        WatchUi.requestUpdate();
        return true;
    }
}
