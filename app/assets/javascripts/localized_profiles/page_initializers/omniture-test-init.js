if (gon.pagename == 'omniture_test') {
    GS.track.baseOmnitureObject.pageName = gon.omniture_pagename;
    GS.track.baseOmnitureObject.hier1 = gon.omniture_hier1;
    var sprops_hash = gon.omniture_sprops;
    var evars_hash = gon.omniture_evars;
    GS.track.setSProps(sprops_hash);
    GS.track.setEVars(evars_hash);


    $(function () {
        //Test omniture event on click of a button.
        $('#omniture_events_test').on('click', function () {
            var omniture_events = 'testEvent1,testEvent2';
            GS.track.trackEvent(omniture_events);
        })

        //Test omniture custom link.
        $('#omniture_custom_link_test').on('click', function () {
            GS.track.sendCustomLink('custom_link_test');
        })

    });
}