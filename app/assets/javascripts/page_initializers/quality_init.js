if(gon.pagename == "Quality"){

    $(function () {
        GS.schoolProfiles.initializeSaveThisSchoolButton();
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
                var $element = $(this);
                var title    = $element.data('title');
                sendEvent($element);

                var $parent = $element.closest('.js-dataVizBarChartContainer');
                $parent.find('.data-viz-bar-chart:not(.js-' + title + ')').addClass('dn');
                $parent.find('.js-' + title).removeClass('dn');
            });
        };

        var dropdownBreakdownsHandler = function() {
            $('.js-dataVizBarChartContainer').on('click', '.js-dataVizDropdown', function () {
                var $element = $(this);
                var title    = $element.data('title');
                sendEvent($element);

                var $parent  = $element.closest('.js-dataVizBarChart');
                var breakdownClass = '.js-' + title;
                $parent.find('.js-barChart').addClass('dn');
                $parent.find('.js-barChart' + breakdownClass).removeClass('dn');
            });
        };

        var sendEvent = function($element) {
          var title    = $element.data('title');
          var category = $element.data('event-category');
          var action   = $element.data('event-action');
          var label    = $element.data('event-label');

          analyticsEvent(category, action, label);
        };

        SubgroupCharts();
        dropdownBreakdownsHandler();


    });


}
