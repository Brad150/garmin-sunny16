import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class sunny16App extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        var interactive = false;
        var settings = System.getDeviceSettings();
        if (settings has :isGlanceModeEnabled) {
            interactive = settings.isGlanceModeEnabled;
        }

        return [new sunny16View(interactive), new sunny16Delegate(interactive)];
    }

    (:glance)
    function getGlanceView() as [WatchUi.GlanceView] or [WatchUi.GlanceView, WatchUi.GlanceViewDelegate] or Null {
        return [new sunny16GlanceView()];
    }

}

function getApp() as sunny16App {
    return Application.getApp() as sunny16App;
}
