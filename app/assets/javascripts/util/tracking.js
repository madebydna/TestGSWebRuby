var GS = GS || {};
GS.track = GS.track || {};
GS.track.baseOmnitureObject = GS.track.baseOmnitureObject || {};

GS.track.setSProps = function (sProps) {
    GS.track.doUnlessTrackingIsDisabled(function () {
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

GS.track.setEVars = function (eVars) {
    GS.track.doUnlessTrackingIsDisabled(function () {
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

GS.track.setEvents = function (eventNames) {
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

//TODO The following tracking is for the events and links that do not have page refresh associated with
// them. Refactor this when omniture requirements come in for these.
GS.track.trackEvent = function (eventNames) {
    GS.track.doUnlessTrackingIsDisabled(function () {
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

GS.track.sendCustomLink = function (linkName) {
    var omnitureObject = {};
    omnitureObject.pageName = GS.track.baseOmnitureObject.pageName;
    if (s.tl) {
        s.tl(true, 'o', linkName, omnitureObject);
    }
    return true;
};

GS.track.doUnlessTrackingIsDisabled = function (cb) {
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
    'custom_completion_sprop':61
};

GS.track.eventLookup = {
    'review_updates_mss_event' : 'event84'
};

//TODO replace these with actual evars when the requirements come in.
GS.track.evarsLookup = {
    'testEvar1':1,
    'testEvar2':2
};

GS.track.setOmnitureData = function () {
    GS.track.baseOmnitureObject.pageName = gon.omniture_pagename;
    GS.track.baseOmnitureObject.hier1 = gon.omniture_hier1;
    if(gon.omniture_school_state != ''){
        GS.track.baseOmnitureObject.channel = gon.omniture_school_state;
    }
    if(typeof gon.omniture_sprops != undefined  && gon.omniture_sprops != null){
        GS.track.setSProps(gon.omniture_sprops);
    }
    if(typeof gon.omniture_events != undefined && gon.omniture_events != null){
        GS.track.setEvents(gon.omniture_events);
    }
};

GS.track.getOmnitureObject = function () {
    //use lowdash to deep clone the omniture object.
    var omnitureObject = _.clone(GS.track.baseOmnitureObject, true);
    return omnitureObject;
};