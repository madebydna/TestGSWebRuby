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


GS.track.trackEvent = function (event_name) {
    GS.track.doUnlessTrackingIsDisabled(function () {
        var myLinkTrackVars = "events";
        var omniture_object = {};
        var mappedEvents = [];
        var eventArray = event_name.split(",");
        for (var i = 0; i < eventArray.length; i++) {
            if (!GS.track.event_lookup[eventArray[i]]) {
                throw "Could not find event mapping for " + eventArray[i];
            }
            mappedEvents.push(GS.track.event_lookup[eventArray[i]]);
        }

        omniture_object.myLinkTrackVars = myLinkTrackVars;
        omniture_object.linkTrackEvents = mappedEvents.join(',');
        omniture_object.pageName = GS.track.base_omniture_object.pageName;
        omniture_object.events = mappedEvents.join(',');
        s.tl(null, 'o', null, omniture_object);
    });
};

GS.track.customLink = function (link_name) {
    var omniture_object = {};
    omniture_object.pageName = GS.track.base_omniture_object.pageName;
    if (s.tl) {
        s.tl(this, 'o', link_name, omniture_object);
    }
    return true;
};


GS.track.doUnlessTrackingIsDisabled = function (cb) {
    if (typeof s !== 'undefined') {
        cb();
    }
};

GS.track.prop_lookup = {
    'test_1_sprop':1,
    'test_2_sprop':2
};

GS.track.event_lookup = {
    'test_event1':'event1',
    'test_event2':'event2'
};

GS.track.evars_lookup = {
    'test_1_evar':1,
    'test_2_evar':2
};
