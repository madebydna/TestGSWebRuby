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
    return {
        adjustSchoolResultsHeights: adjustSchoolResultsHeights
    }
}();

$(document).ready(function () {
    if($('.js-comparedSchool').length > 0) {
        GS.compareSchools.adjustSchoolResultsHeights();
    }
});
