if (gon.pagename == "Details") {

    GS.track.base_omniture_object.pageName = gon.omniture_pagename;
    GS.track.base_omniture_object.hier1 = gon.omniture_hierarchy_1;
    GS.track.base_omniture_object.hier2 = gon.omniture_hierarchy_2;

    $(function () {
        $('body').scrollspy({ target:'.spy-nav' })

    });
}