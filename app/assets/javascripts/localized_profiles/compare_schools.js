//ToDo is it ok to add this conditional to prevent js from executing on every page?
GS.compareSchools = GS.compareSchools || function () {
    var adjustHeights = function (className) {
        var maxHeight = 0;
        $(className).each(function () {
            if ($(this).height() > maxHeight) {
                maxHeight = $(this).height();
            }
        });
        $(className).each(function () {
            $(this).height(maxHeight)
        })
    };

    var adjustSchoolResultsHeights = function () {
        adjustHeights('.js-schoolName');
        adjustHeights('.js-comparePieChartTable');
    };

    var setAccordianHandlerForCategories = function() {
        $('body').on('click', '.js-categoryTitle', function() {
            var $categoryData = $(this).siblings('.js-categoryData');
            var categoryDataClass = '.' + $categoryData.attr('class').split(/\s+/)[0];
            $(categoryDataClass).each(function() {
                  $(this).slideToggle('slow');
            });
        });
    };

    var init = function() {
        adjustSchoolResultsHeights();
        setAccordianHandlerForCategories();
    };

    var pieChartLabelColor = function() {
        var colors = GS.visualchart.colors;
        $('.js-comparePieChartTable').each( function() {
            $(this).children('.js-comparePieChartSquare').each(function (index) {
                $(this).css({ background: colors[index] });
            });
        });
    };

    return {
        init: init,
        pieChartLabelColor: pieChartLabelColor
    };
}();

if (gon.pagename == "CompareSchoolsPage") {
    $(document).ready(function () {
        GS.compareSchools.init();
        GS.compareSchools.pieChartLabelColor();
    });
}
