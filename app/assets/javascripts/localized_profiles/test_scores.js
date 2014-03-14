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


var GS = GS || {};
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

        $('.js_test_scores_about_toggle').on('click', function(){
            if($(this).siblings('div').hasClass('dn')){
                $(this).siblings('div').removeClass('dn');
                $(this).text('Hide');
            }else{
                $(this).siblings('div').addClass('dn');
                $(this).text('Expand');
            }
        });
    };

    return {
        initializeHandlers: initializeHandlers
    }
}(jQuery);
