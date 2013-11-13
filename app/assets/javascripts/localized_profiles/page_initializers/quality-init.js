if(gon.pagename == "Quality"){
    $(function () {
        GS.testScores.initializeHandlers();
        $(".js_grades_div").children().first().trigger( "click" );
    });
}