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
    };

    var setAccordianHandlerForCategories = function() {
        $('body').on('click', '.js-categoryTitle', function() {
            var $categoryData = $(this).siblings('.js-categoryData');
            var categoryDataClass = '.' + $categoryData.attr('class').split(/\s+/)[0];
            var showOrHide = $($(categoryDataClass)[0]).css('display') == 'none' ? show : hide;
            $(categoryDataClass).each(function() {
                showOrHide.apply($(this));
            });
        });
    };

    var show = function() {
        this.show('slow')
    };

    var hide = function() {
        this.hide('slow')
    };

    var init = function() {
        adjustSchoolResultsHeights();
        setAccordianHandlerForCategories();
    };

    var pieChartLabelColor = function() {
        var colors = GS.visualchart.colors;
        $('.js-comparePieChartTable').each( function() {
            console.log($(this).children());
            $(this).children('.js-comparePieChartSquare').each(function (index) {
                console.log(index);
                console.log(colors[index]);
                console.log(this);
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
