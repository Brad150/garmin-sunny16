import Toybox.Lang;
import Toybox.WatchUi;

class sunny16Delegate extends WatchUi.BehaviorDelegate {
    hidden var _view as sunny16View;

    function initialize(view as sunny16View) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onSelect() as Boolean {
        if (!_view.isInteractive()) {
            var next = new sunny16View(true);
            WatchUi.pushView(next, new sunny16Delegate(next), WatchUi.SLIDE_LEFT);
            return true;
        }

        if (_view.step == Sunny16Step.ISO) {
            _view.step = Sunny16Step.LIGHT;
        } else if (_view.step == Sunny16Step.LIGHT) {
            _view.step = Sunny16Step.SCALE;
        } else if (_view.step == Sunny16Step.SCALE) {
            Sunny16State.resetOffset();
        }

        WatchUi.requestUpdate();
        return true;
    }

    function onBack() as Boolean {
        if (_view.step == Sunny16Step.SCALE) {
            _view.step = Sunny16Step.LIGHT;
            WatchUi.requestUpdate();
            return true;
        }
        if (_view.step == Sunny16Step.LIGHT) {
            _view.step = Sunny16Step.ISO;
            WatchUi.requestUpdate();
            return true;
        }
        return false;
    }

    function onPreviousPage() as Boolean {
        if (!_view.isInteractive()) {
            return false;
        }

        if (_view.step == Sunny16Step.ISO) {
            Sunny16State.nextIso();
        } else if (_view.step == Sunny16Step.LIGHT) {
            Sunny16State.previousCondition();
        } else if (_view.step == Sunny16Step.SCALE) {
            Sunny16State.slideWider();
        }

        WatchUi.requestUpdate();
        return true;
    }

    function onNextPage() as Boolean {
        if (!_view.isInteractive()) {
            return false;
        }

        if (_view.step == Sunny16Step.ISO) {
            Sunny16State.previousIso();
        } else if (_view.step == Sunny16Step.LIGHT) {
            Sunny16State.nextCondition();
        } else if (_view.step == Sunny16Step.SCALE) {
            Sunny16State.slideTighter();
        }

        WatchUi.requestUpdate();
        return true;
    }
}
