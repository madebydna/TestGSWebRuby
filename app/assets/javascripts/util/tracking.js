GS.track = GS.track || {};
GS.track.baseOmnitureObject = GS.track.baseOmnitureObject || {};

GS.track.cookieName = 'OmnitureTracking';

GS.track.getOmnitureCookie = function() {
    var omnitureCookie = {};
    if (!(_.isEmpty($.cookie(GS.track.cookieName)))) {
        try {
            omnitureCookie = JSON.parse($.cookie(GS.track.cookieName));
        } catch (e) {
            GS.util.log('Error parsing omniture tracking cookie');
        }
    }
    return omnitureCookie;
};

GS.track.setOmnitureCookie = function(omnitureCookie){
    if (!(_.isEmpty(omnitureCookie))) {
        try {
            $.cookie(GS.track.cookieName,JSON.stringify(omnitureCookie),{path: '/',domain: ".greatschools.org"});
        } catch (e) {
            GS.util.log('Error stringifying omniture tracking cookie');
        }
    }
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

//Use cookies to store the omniture sprops and evars when they need to be tracked on the following page.
GS.track.setSPropsAndEvarsInCookies = function(key,value,omnitureVariable){

    var spropsAndEvars = {};
    var omnitureCookie = GS.track.getOmnitureCookie();

    if(!(_.isEmpty(omnitureCookie[omnitureVariable]))){
        spropsAndEvars = omnitureCookie[omnitureVariable];
    }

    spropsAndEvars[key] = value;
    omnitureCookie[omnitureVariable] = spropsAndEvars;

    GS.track.setOmnitureCookie(omnitureCookie);
};

//Use cookies to store the omniture events when they need to be tracked on the following page.
GS.track.setEventsInCookies = function(event){

    var events = [];
    var omnitureCookie = GS.track.getOmnitureCookie();

    if(!(_.isEmpty(omnitureCookie.events))){
        events = omnitureCookie.events;
    }

    events.push(event);
    omnitureCookie['events'] = $.unique(events);

    GS.track.setOmnitureCookie(omnitureCookie);
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
    'locale':4,
    'searchTerm':6,
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
    'review_updates_mss_traffic_driver' :25,
    'search_page_number': 26,
    'search_page_type': 27
};

GS.track.setOmnitureData = function() {
    GS.track.baseOmnitureObject.pageName = gon.omniture_pagename;
    GS.track.baseOmnitureObject.hier1 = gon.omniture_hier1;
    if(typeof gon.omniture_school_state !== 'undefined'){
        GS.track.baseOmnitureObject.channel = gon.omniture_school_state;
    } else if (typeof gon.omniture_channel !== 'undefined' ){
        GS.track.baseOmnitureObject.channel = gon.omniture_channel;
    }

    var events = [];
    var sprops = {};
    var evars = {};

    if(!(_.isEmpty(gon.omniture_sprops))){
        sprops = gon.omniture_sprops;
    }
    if(!(_.isEmpty(gon.omniture_events))){
        events = gon.omniture_events;
    }
    if(!(_.isEmpty(gon.omniture_evars))){
        evars=gon.omniture_evars;
    }

    var omnitureCookie = GS.track.getOmnitureCookie();
    if (!(_.isEmpty(omnitureCookie))){

        if(!(_.isEmpty(omnitureCookie.sprops))){
            $.extend(sprops, omnitureCookie.sprops);
        }
        if(!(_.isEmpty(omnitureCookie.events))){
            $.merge(events,omnitureCookie.events);
        }
        if(!(_.isEmpty(omnitureCookie.evars))){
            $.extend(evars, omnitureCookie.evars);
        }
    }

    GS.track.setSProps(sprops);
    $.unique(events);
    GS.track.setEvents(events);
    GS.track.setEVars(evars);

    $.removeCookie(GS.track.cookieName, { path: '/' ,domain: ".greatschools.org"});
};

GS.track.getOmnitureObject = function () {
    //use lodash to deep clone the omniture object.
    var omnitureObject = _.clone(GS.track.baseOmnitureObject, true);
    return omnitureObject;
};
