if(gon.pagename == "Quality"){

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

        GS.schoolProfiles.showSignUpForSchoolModalAfterDelay();

        var SubgroupCharts = function () {
            $('.js-barChart').on('click', 'li', function () {
                var title = $(this).text();
                var dashedTitle = title.replace(/ /g, "-");
                var parent = $(this).closest('.js-barChart');
                $('.data-viz-bar-chart:not(.js-' + dashedTitle + ')').addClass('dn');
                $('.js-' + dashedTitle).removeClass('dn');
            });
        };

        $('.data-viz-bar-chart').first().removeClass('dn');
        SubgroupCharts();


    });


}