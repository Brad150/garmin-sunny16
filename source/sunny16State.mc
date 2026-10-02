import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

(:glance)
module Sunny16State {
    const ISO_COUNT as Number = 5;
    const COND_COUNT as Number = 7;

    var isoIndex as Number = 2;
    var condIndex as Number = 1;
    var loaded as Boolean = false;

    function ensureLoaded() as Void {
        if (loaded) {
            return;
        }
        loaded = true;

        var storedIso = Application.Storage.getValue("isoIndex");
        if (storedIso instanceof Number) {
            isoIndex = storedIso as Number;
        }

        var storedCond = Application.Storage.getValue("condIndex");
        if (storedCond instanceof Number) {
            condIndex = storedCond as Number;
        }

        clamp();
    }

    function clamp() as Void {
        if ((isoIndex < 0) || (isoIndex >= ISO_COUNT)) {
            isoIndex = 2;
        }
        if ((condIndex < 0) || (condIndex >= COND_COUNT)) {
            condIndex = 1;
        }
    }

    function save() as Void {
        Application.Storage.setValue("isoIndex", isoIndex);
        Application.Storage.setValue("condIndex", condIndex);
    }

    function isoValue() as Number {
        ensureLoaded();
        if (isoIndex == 0) {
            return 100;
        }
        if (isoIndex == 1) {
            return 200;
        }
        if (isoIndex == 2) {
            return 400;
        }
        if (isoIndex == 3) {
            return 800;
        }
        return 1600;
    }

    function nextIso() as Void {
        ensureLoaded();
        isoIndex = (isoIndex + 1) % ISO_COUNT;
        save();
    }

    function nextCondition() as Void {
        ensureLoaded();
        condIndex = (condIndex + 1) % COND_COUNT;
        save();
    }

    function previousCondition() as Void {
        ensureLoaded();
        condIndex -= 1;
        if (condIndex < 0) {
            condIndex = COND_COUNT - 1;
        }
        save();
    }

    function conditionName() as String {
        ensureLoaded();
        if (condIndex == 0) {
            return WatchUi.loadResource(Rez.Strings.CondSnowSand) as String;
        }
        if (condIndex == 1) {
            return WatchUi.loadResource(Rez.Strings.CondSunny) as String;
        }
        if (condIndex == 2) {
            return WatchUi.loadResource(Rez.Strings.CondSlightOvercast) as String;
        }
        if (condIndex == 3) {
            return WatchUi.loadResource(Rez.Strings.CondOvercast) as String;
        }
        if (condIndex == 4) {
            return WatchUi.loadResource(Rez.Strings.CondHeavyOvercast) as String;
        }
        if (condIndex == 5) {
            return WatchUi.loadResource(Rez.Strings.CondOpenShade) as String;
        }
        return WatchUi.loadResource(Rez.Strings.CondSunset) as String;
    }

    function apertureLabel() as String {
        ensureLoaded();
        if (condIndex == 0) {
            return WatchUi.loadResource(Rez.Strings.Aperture22) as String;
        }
        if (condIndex == 1) {
            return WatchUi.loadResource(Rez.Strings.Aperture16) as String;
        }
        if (condIndex == 2) {
            return WatchUi.loadResource(Rez.Strings.Aperture11) as String;
        }
        if (condIndex == 3) {
            return WatchUi.loadResource(Rez.Strings.Aperture8) as String;
        }
        if (condIndex == 4) {
            return WatchUi.loadResource(Rez.Strings.Aperture56) as String;
        }
        if (condIndex == 5) {
            return WatchUi.loadResource(Rez.Strings.Aperture4) as String;
        }
        return WatchUi.loadResource(Rez.Strings.Aperture28) as String;
    }

    function shutterLabel() as String {
        ensureLoaded();
        return (WatchUi.loadResource(Rez.Strings.ShutterPrefix) as String) + isoValue().toString();
    }

    function exposureLabel() as String {
        return apertureLabel() + "  " + shutterLabel();
    }

    function isoLabel() as String {
        return (WatchUi.loadResource(Rez.Strings.IsoPrefix) as String) + isoValue().toString();
    }
}
