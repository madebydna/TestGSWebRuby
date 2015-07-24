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
            $('.js-dataVizBarChartContainer').on('click', 'li', function () {
                var title = $(this).text();
                var dashedTitle = title.replace(/ /g, "-");
                $('.js-dataVizBarChart:not(.js-' + dashedTitle + ')').addClass('dn');
                $('.js-' + dashedTitle).removeClass('dn');
            });
        };

        $('.js-dataVizBarChart').first().removeClass('dn');
        SubgroupCharts();

        var toggleBreakdownsHandler = function() {
            $('.js-dataVizBarChartContainer').on('click', '.js-barChartBreakdown', function () {
                var $self = $(this);
                var breakdownClass = '.js-' + $self.data('breakdown')
                var $parent = $self.closest('.js-dataVizBarChart');

                $parent.find('.js-barChart').addClass('dn')
                $parent.find('.js-barChart' + breakdownClass).removeClass('dn')
            });
        }

        toggleBreakdownsHandler()


    });


}
