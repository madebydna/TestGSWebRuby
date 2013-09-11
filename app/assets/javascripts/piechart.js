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
GS.piechart = GS.piechart || function($) {

    var loader = [];
    $.getScript("https://www.google.com/jsapi", function() {
        google.load("visualization", "1", {packages:["corechart"], callback:function(){
            for (var x=0; x < loader.length; x++) {
                loader[x]();
            }
            loader = undefined;
        }});
    });

    var pieSelectHandler = function selectHandler() {
        GS.tracking.sendOmnitureData('demographics');
        GS.tabManager.showTabWithOptions({tab:'demographics', hash:'header'});
    };

    var colors = ['#4393B5','#38A37A','#84D07C','#E2B66C','#E2937D','#DA5F6E','#B66483','#7B498F','#414F7B','#A7A7A7','#7CC7CE','#489A9D','#A4CEBB','#649644','#E0D152','#F1A628','#A3383A','#8C734D','#EA6394','#CE92C0','#5A78B1'];

    var drawPieChart = function(dataIn, divId, selectHandler, options) {
        var func = function() {
            // Create and populate the data table.
            var data = google.visualization.arrayToDataTable(dataIn, true);

            var defaultOptions = {
                width: 200,
                height: 200,
                legend: {
                    alignment: 'center'
                },
                tooltip: {
                    showColorCode: true,
                    text:'value',
                    textStyle: {
                        color: '#2b2b2b',
                        fontName: 'Arial',
                        fontSize: '10'
                    }
                },
                colors: colors,
                pieSliceText: 'none',
                chartArea:{left:15,top:15,bottom:10,right:10,width:"80%",height:"80%"},
                pieSliceBorderColor:'white'

            };

            $.extend(true, defaultOptions, options);

            // Create and draw the visualization.
            var pieChart = new google.visualization.PieChart(document.getElementById(divId));
            pieChart.draw(data, defaultOptions);

            if(selectHandler){
                google.visualization.events.addListener(pieChart, 'select', selectHandler);
            }
        };

        if (loader) {
            loader.push(func);
        } else {
            google.setOnLoadCallback(func);
        }
    };

    return {
        colors: colors,
        pieSelectHandler: pieSelectHandler,
        drawPieChart: drawPieChart,
        loader: loader
    }

}(jQuery);
