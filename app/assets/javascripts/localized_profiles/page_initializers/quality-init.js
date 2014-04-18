if(gon.pagename == "Quality"){

    GS.track.setOmnitureData();

    $(function () {
        GS.testScores.initializeHandlers();

        //Show the first grade in every test
        var func = function () {
            $('.js_grades_div').each(function () {
                $(this).children().first().trigger("click");
            });
        }

        if (GS.visualchart.loader) {
            GS.visualchart.loader.push(func);
        } else {
            google.setOnLoadCallback(func);
        }
    });
}