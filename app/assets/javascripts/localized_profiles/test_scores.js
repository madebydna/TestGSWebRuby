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
            var breakdown = $(this).attr("id").split("_")[2];
            var grade_id = $(this).attr("id").split("_")[3];

            var filter_title = $(this).html();
            var filter_title_link = $(this).find('a').html();
            if(filter_title_link){
              filter_title = filter_title_link;
            }
            $('.js_button-filter-title').html(filter_title);
            var classToHide = ".js_"+test_id+"_grades";
            var idToShow = _(["#js", test_id, breakdown, grade_id, 'scores']).join('_');

            $(classToHide).addClass("dn");
            $(idToShow).removeClass("dn");

            // when user clicks a group, un-highlight grade buttons
            // when user clicks grade button, un-highlight group button
            if ($(this).is('button')) {
              $('.js_test_groups').children('.btn.active').removeClass('active');
            } else {
              $('.js_test_scores_grades.btn.active').removeClass('active');
              $('.js_test_groups .btn').addClass('active');
            }
        });
    };

    return {
        initializeHandlers: initializeHandlers
    }
}(jQuery);
