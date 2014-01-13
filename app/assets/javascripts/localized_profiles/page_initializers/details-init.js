if (gon.pagename == "Details") {
    GS.track.base_omniture_object.pageName = gon.omniture_pagename;
    GS.track.base_omniture_object.hier1 = gon.omniture_pagename;
    var sprops_hash = gon.omniture_sprops;
    var evars_hash = gon.omniture_evars;
    GS.track.setSProps(sprops_hash);
    GS.track.setEVars(evars_hash);


    $(function () {
        $('body').scrollspy({ target:'.spy-nav' })
  //Set events on a particular event.
    var omniture_events = "details_event1,details_event2";
    GS.track.trackEvent(omniture_events);
    });
}