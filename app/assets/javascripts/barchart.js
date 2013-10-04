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
GS.barchart = GS.barchart || function($) {

    var loader = [];
    $.getScript("https://www.google.com/jsapi", function() {
        google.load("visualization", "1", {packages:["corechart"], callback:function(){
            for (var x=0; x < loader.length; x++) {
                loader[x]();
            }
            loader = undefined;
        }});
    });

    var drawBarChart = function (barChartData,div) {
        var func = function () {
            var data = google.visualization.arrayToDataTable(barChartData);

            var options = {};

            var chart = new google.visualization.BarChart(document.getElementById(div));
            chart.draw(data, options);

        }
        if (loader) {
            loader.push(func);
        } else {
            google.setOnLoadCallback(func);
        };
    };

    return {
        drawBarChart: drawBarChart,
        loader: loader
    }

}(jQuery);
