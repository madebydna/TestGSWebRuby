if(gon.pagename == "Quality"){

    $(function () {
        GS.schoolProfiles.initializeSaveThisSchoolButton();
        GS.schoolProfiles.initializeFollowThisSchool();
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

        GS.schoolProfiles.showSignUpForSchoolModalAfterDelay();
        GS.dataViz.initToggleHandlers();
        GS.nearbySchools.initialize();
    });
}
