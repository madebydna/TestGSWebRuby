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
            $('.js-dataVizBarChartContainer').on('click', '.js-barChartBreakdown', function () {
                var title = $(this).data('breakdown');
                var dashedTitle = title.replace(/ /g, "-");
                var $parent = $(this).closest('.js-dataVizBarChartContainer');
                $parent.find('.data-viz-bar-chart:not(.js-' + dashedTitle + ')').addClass('dn');
                $parent.find('.js-' + dashedTitle).removeClass('dn');
            });
        };

        var dropdownBreakdownsHandler = function() {
            $('.js-dataVizBarChartContainer').on('click', 'li', function () {
                var $self = $(this).text();
                var dashedTitle = $self.replace(/ /g, "-");
                var breakdownClass = '.js-' + dashedTitle;
                var $parent = $(this).closest('.js-dataVizBarChart');

                $parent.find('.js-barChart').addClass('dn');
                $parent.find('.js-barChart' + breakdownClass).removeClass('dn');
            });
        };

        SubgroupCharts();
        dropdownBreakdownsHandler();


    });


}
