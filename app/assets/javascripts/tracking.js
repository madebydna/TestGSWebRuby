var GS = GS || {};
GS.track = GS.track || {};
GS.track.baseOmnitureObject = GS.track.baseOmnitureObject || {};

//TODO do we need linkTrackVars and linkTrackEvents while setting sprops and evars?
//TODO add the linkTrackVars and linkTrackEvents when needed.

GS.track.setSProps = function (sProps) {
    GS.track.doUnlessTrackingIsDisabled(function () {
        var missingProps = [];
        for (var p in sProps) {
            if (!GS.track.propLookup[p]) {
                missingProps.push(p);
            } else {
                GS.track.baseOmnitureObject['prop' + GS.track.propLookup[p]] = sProps[p];
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
            if (!GS.track.evarsLookup[p]) {
                missingEvars.push(p);
            } else {
                GS.track.baseOmnitureObject['eVar' + GS.track.evarsLookup[p]] = eVars[p];
            }
        }
        if (missingEvars.length > 0) {
            GS.util.log('Evars missing for the following:' + missingEvars);
        }
    });
};

GS.track.trackEvent = function (eventName) {
    GS.track.doUnlessTrackingIsDisabled(function () {
        var myLinkTrackVars = "events";
        var omnitureObject = {};
        var mappedEvents = [];
        var missingEvents = [];
        var eventArray = eventName.split(",");
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
    'navBarVariant':58
};

//TODO replace these with actual evars and events when the requirements come in.
GS.track.eventLookup = {
    'testEvent1':'event1',
    'testEvent2':'event2'
};

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
    var spropsHash = gon.omniture_sprops;
    GS.track.setSProps(spropsHash);
};

GS.track.getOmnitureObject = function () {
    //use lowdash to deep clone the omniture object.
    var omnitureObject = _.clone(GS.track.baseOmnitureObject, true);
    return omnitureObject;
};