if (gon.pagename == 'Omniture_test') {
    GS.track.base_omniture_object.pageName = gon.omniture_pagename;
    GS.track.base_omniture_object.hier1 = gon.omniture_pagename;
    var sprops_hash = gon.omniture_sprops;
    var evars_hash = gon.omniture_evars;
    GS.track.setSProps(sprops_hash);
    GS.track.setEVars(evars_hash);


    $(function () {
        //Test omniture event on click of a button.
        $('#omniture_events_test').on('click', function () {
            var omniture_events = 'test_event1,test_event2';
            GS.track.trackEvent(omniture_events);
        })

        //Test omniture custom link.
        $('#omniture_custom_link_test').on('click', function () {
            GS.track.customLink('custom_link_test');
        })

    });
}