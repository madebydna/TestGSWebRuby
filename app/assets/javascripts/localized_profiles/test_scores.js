/********************************************************************************************************
 *
 * GS files
 *  profilePage.js
 *  pieChart.tagx
 *  profileOverviewDiversityTile.tagx
 *  profile.jspx
 *  schoolProfilePieChartTable.tagx
 *
 */


GS.testScores = GS.testScores || function($) {

    var initializeHandlers = function () {
        $(".js_test_scores_grades").on("click", function(){
            var test_id = $(this).attr("id").split("_")[1];
            var grade_id = $(this).attr("id").split("_")[2];

            var classToHide = ".js_"+test_id+"_grades";
            var idToShow = "#js_"+test_id+"_"+grade_id+"_scores";

            $(classToHide).addClass("dn");
            $(idToShow).removeClass("dn");
        });
    };

    return {
        initializeHandlers: initializeHandlers
    }
}(jQuery);
