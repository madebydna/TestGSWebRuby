var GS = GS || {};
GS.track = GS.track || {};
GS.track.base_omniture_object = GS.track.base_omniture_object || {};

//TODO do we need linkTrackVars and linkTrackEvents while setting sprops and evars?
//TODO add the linkTrackVars and linkTrackEvents when needed.

GS.track.setSProps = function (s_props) {
    GS.track.doUnlessTrackingIsDisabled(function () {
        var missing_props = [];
        for (var p in s_props) {
            if (!GS.track.prop_lookup[p]) {
                missing_props.push(p);
            } else {
                GS.track.base_omniture_object['prop' + GS.track.prop_lookup[p]] = s_props[p];
            }
        }
        if(missing_props.length >0){
            if(window.console) console.log('Sprops missing for the following:'+missing_props);
        }
    });
};

GS.track.setEVars = function (evars) {
    GS.track.doUnlessTrackingIsDisabled(function () {
        var missing_evars = [];
        for (var p in evars) {
            if (!GS.track.evars_lookup[p]) {
                missing_evars.push(p);
            } else {
                GS.track.base_omniture_object['eVar' + GS.track.evars_lookup[p]] = evars[p];
            }
        }
        if(missing_evars.length >0){
            if(window.console) console.log('Evars missing for the following:'+missing_evars);
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
    'school_id':1,
    'school_type':2,
    'school_level':3,
    'school_locale':4,
    'school_rating':31,
    'user_login_status':5,
    'request_url':59,
    'query_string':60,
    'local_page_name':57,
    'nav_bar_variant':58
};

//TODO replace these with actual evars and events when the requirements come in.
GS.track.event_lookup = {
    'test_event1':'event1',
    'test_event2':'event2'
};

GS.track.evars_lookup = {
    'test_1_evar':1,
    'test_2_evar':2
};

GS.track.set_common_omniture_data = function () {
    GS.track.base_omniture_object.pageName = gon.omniture_pagename;
    GS.track.base_omniture_object.hier1 = gon.omniture_hier1;
    var sprops_hash = gon.omniture_sprops;
    GS.track.setSProps(sprops_hash);
};

GS.track.get_omniture_object = function () {
    //use lowdash to deep clone the omniture object.
    var omniture_object = _.clone(GS.track.base_omniture_object, true);
    return omniture_object;
};