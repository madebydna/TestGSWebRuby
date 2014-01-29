if(gon.pagename == "Quality"){

    GS.track.base_omniture_object.pageName = gon.omniture_pagename;
    GS.track.base_omniture_object.hier1 = gon.omniture_hierarchy_1;
    GS.track.base_omniture_object.hier2 = gon.omniture_hierarchy_2;

    $(function () {
        GS.testScores.initializeHandlers();
        var func = function () {
            $(".js_grades_div").children().first().trigger( "click" );
        }
        if (GS.visualchart.loader) {
            GS.visualchart.loader.push(func);
        } else {
            google.setOnLoadCallback(func);
        }
    });
}