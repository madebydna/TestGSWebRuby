var GS = GS || {};
GS.track = GS.track || {};
GS.track.base_omniture_object = GS.track.base_omniture_object || {};
GS.track.setSProps = function (s_props) {
    GS.track.doUnlessTrackingIsDisabled(function () {
        var myLinkTrackVars = "events,"; //Always include events, even if we don't need it
        for (var p in s_props) {
            if (!GS.track.prop_lookup[p]) {
                throw "No mapping found for " + p;
            }
            myLinkTrackVars += "prop" + GS.track.prop_lookup[p] + ",";
        }
        GS.track.base_omniture_object.linkTrackVars = myLinkTrackVars;

        GS.track.base_omniture_object.linkTrackEvents = 'None';

        for (var p in s_props) {
            GS.track.base_omniture_object['prop' + GS.track.prop_lookup[p]] = s_props[p];
        }
    });
};

GS.track.setEVars = function (evars) {
    GS.track.doUnlessTrackingIsDisabled(function () {
        var myLinkTrackVars = "events,"; //Always include events, even if we don't need it
        for (var p in evars) {
            if (!GS.track.evars_lookup[p]) {
                throw "No mapping found for " + p;
            }
            myLinkTrackVars += "eVar" + GS.track.evars_lookup[p] + ",";
        }
        GS.track.base_omniture_object.linkTrackVars = myLinkTrackVars;

        GS.track.base_omniture_object.linkTrackEvents = 'None';

        for (var p in evars) {
            GS.track.base_omniture_object['eVar' + GS.track.evars_lookup[p]] = evars[p];
        }
    });
};


GS.track.trackEvent = function (eventName) {
    GS.track.doUnlessTrackingIsDisabled(function () {
        var omniture_object = {};
        var mappedEvents = [];
        var eventArray = eventName.split(",");
        for (var i = 0; i < eventArray.length; i++) {
            if (!GS.track.event_lookup[eventArray[i]]) {
                throw "Could not find event mapping for " + eventArray[i];
            }
            mappedEvents.push(GS.track.event_lookup[eventArray[i]]);
        }

        omniture_object.linkTrackEvents = mappedEvents.join(',');
        omniture_object.events = mappedEvents.join(',');
        s.tl(null, 'o', null, omniture_object);
    });
};

GS.track.doUnlessTrackingIsDisabled = function (cb) {
    if (typeof s !== 'undefined') {
        cb();
    }
};

GS.track.prop_lookup = {
    'some_sprop':1,
    'some_sprop_test':3
};

GS.track.event_lookup = {
    'details_event1':'event4',
    'details_event2':'event5'
};

GS.track.evars_lookup = {
    'some_evars':1,
    'some_evars_test':2
};
