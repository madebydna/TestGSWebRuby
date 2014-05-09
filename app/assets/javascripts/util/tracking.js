GS.track = GS.track || {};
GS.track.baseOmnitureObject = GS.track.baseOmnitureObject || {};

GS.track.cookie_name = 'OmnitureTracking';

GS.track.getOmnitureCookie = function() {
    var omniture_cookie = {};
    if (!(_.isEmpty($.cookie(GS.track.cookie_name)))) {
        try {
            omniture_cookie = JSON.parse($.cookie(GS.track.cookie_name));
        } catch (e) {
            GS.util.log('Error parsing omniture tracking cookie');
        }
    }
    return omniture_cookie;
};

GS.track.setSProps = function(sProps) {
    GS.track.doUnlessTrackingIsDisabled(function() {
        var missingProps = [];
        for (var p in sProps) {
            if (sProps.hasOwnProperty(p)) {
                if (!GS.track.propLookup[p]) {
                    missingProps.push(p);
                } else {
                    GS.track.baseOmnitureObject['prop' + GS.track.propLookup[p]] = sProps[p];
                }
            }
        }
        if (missingProps.length > 0) {
            GS.util.log('Sprops missing for the following:' + missingProps);
        }
    });
};

GS.track.setEVars = function(eVars) {
    GS.track.doUnlessTrackingIsDisabled(function() {
        var missingEvars = [];
        for (var p in eVars) {
            if (eVars.hasOwnProperty(p)) {
                if (!GS.track.evarsLookup[p]) {
                    missingEvars.push(p);
                } else {
                    GS.track.baseOmnitureObject['eVar' + GS.track.evarsLookup[p]] = eVars[p];
                }
            }
        }
        if (missingEvars.length > 0) {
            GS.util.log('Evars missing for the following:' + missingEvars);
        }
    });
};

GS.track.setEvents = function(eventNames) {
    GS.track.doUnlessTrackingIsDisabled(function () {
        var mappedEvents = [];
        var missingEvents = [];
        for (var i = 0; i < eventNames.length; i++) {
                if (!GS.track.eventLookup[eventNames[i]]) {
                    missingEvents.push(eventNames[i]);
                } else {
                    mappedEvents.push(GS.track.eventLookup[eventNames[i]]);
                }
        }
        //Events should be comma-separated, NOT semi-colon separated.Java project has it wrong.
        GS.track.baseOmnitureObject.events = mappedEvents.join(',');
        if (missingEvents.length > 0) {
            GS.util.log('Events missing for the following:' + missingEvents);
        }
    });
};

GS.track.setSPropsInCookies = function(key,value){

    var sprops = {};
    var omniture_cookie = GS.track.getOmnitureCookie();

    if(typeof omniture_cookie.sprops != undefined  && omniture_cookie.sprops != null){
        sprops = omniture_cookie.sprops;
    }

    sprops[key] = value;
    omniture_cookie['sprops'] = sprops;

    $.cookie(GS.track.cookie_name,JSON.stringify(omniture_cookie),{path: '/'});
};

GS.track.setEVarsInCookies = function(key,value){

    var evars = {};
    var omniture_cookie = GS.track.getOmnitureCookie();

    if(typeof omniture_cookie.evars != undefined  && omniture_cookie.evars != null){
        evars = omniture_cookie.evars;
    }

    evars[key] = value;
    omniture_cookie['evars'] = evars;

    $.cookie(GS.track.cookie_name,JSON.stringify(omniture_cookie),{path: '/'});
};

GS.track.setEventsInCookies = function(event){

    var events = [];
    var omniture_cookie = GS.track.getOmnitureCookie();

    if(typeof omniture_cookie.events != undefined && omniture_cookie.events != null){
        events = omniture_cookie.events;
    }

    events.push(event);
    omniture_cookie['events'] = $.unique(events);

    $.cookie(GS.track.cookie_name,JSON.stringify(omniture_cookie),{path: '/'});
};



//TODO The following tracking is for the events and links that do not have page refresh associated with
// them. Refactor this when omniture requirements come in for these.
GS.track.trackEvent = function(eventNames) {
    GS.track.doUnlessTrackingIsDisabled(function() {
        var myLinkTrackVars = "events";
        var omnitureObject = {};
        var mappedEvents = [];
        var missingEvents = [];
        var eventArray = eventNames.split(",");
        for (var i = 0; i < eventArray.length; i++) {
            if (!GS.track.eventLookup[eventArray[i]]) {
                missingEvents.push(eventArray[i]);
            }else{
                mappedEvents.push(GS.track.eventLookup[eventArray[i]]);
            }
        }

        omnitureObject.myLinkTrackVars = myLinkTrackVars;
        omnitureObject.linkTrackEvents = mappedEvents.join(',');
        omnitureObject.pageName = GS.track.baseOmnitureObject.pageName;
        omnitureObject.events = mappedEvents.join(',');
        if (s.tl) {
            s.tl(null, 'o', null, omnitureObject);
        }
        if (missingEvents.length > 0) {
            GS.util.log('Events missing for the following:' + missingEvents);
        }
    });
};

GS.track.sendCustomLink = function(linkName) {
    var omnitureObject = {};
    omnitureObject.pageName = GS.track.baseOmnitureObject.pageName;
    if (s.tl) {
        s.tl(true, 'o', linkName, omnitureObject);
    }
    return true;
};

GS.track.doUnlessTrackingIsDisabled = function(cb) {
    if (typeof s !== 'undefined') {
        cb();
    }
};

GS.track.propLookup = {
    'schoolId':1,
    'schoolType':2,
    'schoolLevel':3,
    'schoolLocale':4,
    'schoolRating':31,
    'userLoginStatus':5,
    'requestUrl':59,
    'queryString':60,
    'localPageName':57,
    'navBarVariant':58,
    'custom_completion_sprop':61 //This sprop is set to track both the start and end of conversion funnel.ANA-43 and OM-263.
};

GS.track.eventLookup = {
    'review_updates_mss_end_event' : 'event84', //Event to track the end of conversion funnel.ANA-43
    'review_updates_mss_start_event' : 'event85' //Event to track the start of conversion funnel.OM-263
};

GS.track.evarsLookup = {
    'review_updates_mss_traffic_driver' :25
};

GS.track.setOmnitureData = function() {
    GS.track.baseOmnitureObject.pageName = gon.omniture_pagename;
    GS.track.baseOmnitureObject.hier1 = gon.omniture_hier1;
    if(gon.omniture_school_state != ''){
        GS.track.baseOmnitureObject.channel = gon.omniture_school_state;
    }

    var events = [];
    var sprops = {};
    var evars = {};

    if(typeof gon.omniture_sprops != undefined  && gon.omniture_sprops != null){
        sprops = gon.omniture_sprops;
    }

    if(typeof gon.omniture_events != undefined && gon.omniture_events != null){
        events = gon.omniture_events;
    }
    if(typeof gon.omniture_evars != undefined  && gon.omniture_evars != null){
        evars=gon.omniture_evars;
    }

    if($.cookie(GS.track.cookie_name) != null){
        var omniture_cookie = GS.track.getOmnitureCookie();

        if(typeof omniture_cookie.sprops != undefined  && omniture_cookie.sprops != null){
            $.extend(sprops, omniture_cookie.sprops);
        }

        if(typeof omniture_cookie.events != undefined  && omniture_cookie.events != null){
            $.merge(events,omniture_cookie.events);
        }
        if(typeof omniture_cookie.evars != undefined  && omniture_cookie.evars != null){
            $.extend(evars, omniture_cookie.evars);
        }
    }

    GS.track.setSProps(sprops);
    $.unique(events);
    GS.track.setEvents(events);
    GS.track.setEVars(evars);

    $.removeCookie(GS.track.cookie_name, { path: '/' });
};

GS.track.getOmnitureObject = function () {
    //use lowdash to deep clone the omniture object.
    var omnitureObject = _.clone(GS.track.baseOmnitureObject, true);
    return omnitureObject;
};