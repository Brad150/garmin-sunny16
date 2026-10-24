import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

(:glance)
module Sunny16State {
    const ISO_COUNT as Number = 7;
    const COND_COUNT as Number = 7;
    const APERTURE_COUNT as Number = 10;
    const SHUTTER_COUNT as Number = 13;
    const STATE_VERSION as Number = 2;

    // Index 3 is ISO 400. Index 1 is Sunny.
    var isoIndex as Number = 3;
    var condIndex as Number = 1;
    var stopOffset as Number = 0;
    var loaded as Boolean = false;

    function ensureLoaded() as Void {
        if (loaded) {
            return;
        }
        loaded = true;

        var version = Application.Storage.getValue("stateVersion");
        if ((version instanceof Number) && ((version as Number) == STATE_VERSION)) {
            var storedIso = Application.Storage.getValue("iso");
            if (storedIso instanceof Number) {
                isoIndex = indexForIso(storedIso as Number);
            }

            var storedCond = Application.Storage.getValue("condIndex");
            if (storedCond instanceof Number) {
                condIndex = storedCond as Number;
            }

            var storedOffset = Application.Storage.getValue("stopOffset");
            if (storedOffset instanceof Number) {
                stopOffset = storedOffset as Number;
            }
        } else {
            var legacyIndex = Application.Storage.getValue("isoIndex");
            if (legacyIndex instanceof Number) {
                isoIndex = indexForIso(legacyIso(legacyIndex as Number));
            }

            var legacyCond = Application.Storage.getValue("condIndex");
            if (legacyCond instanceof Number) {
                condIndex = legacyCond as Number;
            }

            stopOffset = 0;
            clamp();
            save();
            return;
        }

        clamp();
    }

    function clamp() as Void {
        if ((isoIndex < 0) || (isoIndex >= ISO_COUNT)) {
            isoIndex = 3;
        }
        if ((condIndex < 0) || (condIndex >= COND_COUNT)) {
            condIndex = 1;
        }
        clampOffset();
    }

    function save() as Void {
        Application.Storage.setValue("stateVersion", STATE_VERSION);
        Application.Storage.setValue("iso", isoValue());
        Application.Storage.setValue("condIndex", condIndex);
        Application.Storage.setValue("stopOffset", stopOffset);
    }

    function legacyIso(index as Number) as Number {
        if (index == 0) {
            return 100;
        }
        if (index == 1) {
            return 200;
        }
        if (index == 2) {
            return 400;
        }
        if (index == 3) {
            return 800;
        }
        if (index == 4) {
            return 1600;
        }
        return 400;
    }

    function indexForIso(iso as Number) as Number {
        var i = 0;
        for (i = 0; i < ISO_COUNT; i += 1) {
            if (isoAt(i) == iso) {
                return i;
            }
        }
        return 3;
    }

    function isoAt(index as Number) as Number {
        if (index == 0) {
            return 50;
        }
        if (index == 1) {
            return 100;
        }
        if (index == 2) {
            return 200;
        }
        if (index == 3) {
            return 400;
        }
        if (index == 4) {
            return 800;
        }
        if (index == 5) {
            return 1600;
        }
        return 3200;
    }

    function isoValue() as Number {
        ensureLoaded();
        return isoAt(isoIndex);
    }

    function nextIso() as Void {
        ensureLoaded();
        isoIndex += 1;
        if (isoIndex >= ISO_COUNT) {
            isoIndex = 0;
        }
        clampOffset();
        save();
    }

    function previousIso() as Void {
        ensureLoaded();
        isoIndex -= 1;
        if (isoIndex < 0) {
            isoIndex = ISO_COUNT - 1;
        }
        clampOffset();
        save();
    }

    function nextCondition() as Void {
        ensureLoaded();
        condIndex = (condIndex + 1) % COND_COUNT;
        clampOffset();
        save();
    }

    function previousCondition() as Void {
        ensureLoaded();
        condIndex -= 1;
        if (condIndex < 0) {
            condIndex = COND_COUNT - 1;
        }
        clampOffset();
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

    // cond 0 is f/22 (aperture index 8). Each darker condition opens one stop.
    function baseApertureIndex() as Number {
        ensureLoaded();
        return 8 - condIndex;
    }

    // ISO 50 is 1/60 (shutter index 6). Each faster ISO is one stop faster.
    function baseShutterIndex() as Number {
        ensureLoaded();
        return 6 + isoIndex;
    }

    function maxStopOffset() as Number {
        var apertureRoom = baseApertureIndex();
        var shutterRoom = (SHUTTER_COUNT - 1) - baseShutterIndex();
        if (apertureRoom < shutterRoom) {
            return apertureRoom;
        }
        return shutterRoom;
    }

    function minStopOffset() as Number {
        var apertureRoom = baseApertureIndex() - (APERTURE_COUNT - 1);
        var shutterRoom = 0 - baseShutterIndex();
        if (apertureRoom > shutterRoom) {
            return apertureRoom;
        }
        return shutterRoom;
    }

    function clampOffset() as Void {
        var minOff = minStopOffset();
        var maxOff = maxStopOffset();
        if (stopOffset > maxOff) {
            stopOffset = maxOff;
        }
        if (stopOffset < minOff) {
            stopOffset = minOff;
        }
    }

    function slideWider() as Void {
        ensureLoaded();
        stopOffset += 1;
        if (stopOffset > maxStopOffset()) {
            stopOffset = minStopOffset();
        }
        save();
    }

    function slideTighter() as Void {
        ensureLoaded();
        stopOffset -= 1;
        if (stopOffset < minStopOffset()) {
            stopOffset = maxStopOffset();
        }
        save();
    }

    function resetOffset() as Void {
        ensureLoaded();
        stopOffset = 0;
        save();
    }

    function apertureLabel(index as Number) as String {
        if (index == 0) {
            return WatchUi.loadResource(Rez.Strings.Aperture14) as String;
        }
        if (index == 1) {
            return WatchUi.loadResource(Rez.Strings.Aperture2) as String;
        }
        if (index == 2) {
            return WatchUi.loadResource(Rez.Strings.Aperture28) as String;
        }
        if (index == 3) {
            return WatchUi.loadResource(Rez.Strings.Aperture4) as String;
        }
        if (index == 4) {
            return WatchUi.loadResource(Rez.Strings.Aperture56) as String;
        }
        if (index == 5) {
            return WatchUi.loadResource(Rez.Strings.Aperture8) as String;
        }
        if (index == 6) {
            return WatchUi.loadResource(Rez.Strings.Aperture11) as String;
        }
        if (index == 7) {
            return WatchUi.loadResource(Rez.Strings.Aperture16) as String;
        }
        if (index == 8) {
            return WatchUi.loadResource(Rez.Strings.Aperture22) as String;
        }
        return WatchUi.loadResource(Rez.Strings.Aperture32) as String;
    }

    function shutterDenom(index as Number) as Number {
        if (index == 1) {
            return 2;
        }
        if (index == 2) {
            return 4;
        }
        if (index == 3) {
            return 8;
        }
        if (index == 4) {
            return 15;
        }
        if (index == 5) {
            return 30;
        }
        if (index == 6) {
            return 60;
        }
        if (index == 7) {
            return 125;
        }
        if (index == 8) {
            return 250;
        }
        if (index == 9) {
            return 500;
        }
        if (index == 10) {
            return 1000;
        }
        if (index == 11) {
            return 2000;
        }
        return 4000;
    }

    function shutterLabel(index as Number) as String {
        if (index <= 0) {
            return WatchUi.loadResource(Rez.Strings.Shutter1s) as String;
        }
        return (WatchUi.loadResource(Rez.Strings.ShutterPrefix) as String) + shutterDenom(index).toString();
    }

    function apertureLabelForOffset(offset as Number) as String {
        return apertureLabel(baseApertureIndex() - offset);
    }

    function shutterLabelForOffset(offset as Number) as String {
        return shutterLabel(baseShutterIndex() + offset);
    }

    function pairLabel(offset as Number) as String {
        return apertureLabelForOffset(offset) + "  " + shutterLabelForOffset(offset);
    }

    function selectedPairLabel() as String {
        ensureLoaded();
        return pairLabel(stopOffset);
    }

    function basePairLabel() as String {
        ensureLoaded();
        return pairLabel(0);
    }

    function isoLabel() as String {
        return (WatchUi.loadResource(Rez.Strings.IsoPrefix) as String) + isoValue().toString();
    }
}
