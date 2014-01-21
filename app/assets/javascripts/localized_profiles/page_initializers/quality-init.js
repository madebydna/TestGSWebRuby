if(gon.pagename == "Quality"){
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