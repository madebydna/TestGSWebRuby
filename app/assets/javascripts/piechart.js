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



var GS_PieLoader = [];
$.getScript("https://www.google.com/jsapi", function() {
    google.load("visualization", "1", {packages:["corechart"], callback:function(){
        for (var x=0; x &lt; GS_PieLoader.length; x++) {
            GS_PieLoader[x]();
        }
        GS_PieLoader = undefined;
    }});
});

function drawPieChart(dataIn, divNameId, dimensions, catchClick) {

    // Create and populate the data table.
    var data = google.visualization.arrayToDataTable(dataIn, true);

    var options = {
        width: dimensions,
        height: dimensions,
        legend: 'none',
        tooltip: {showColorCode: true,text:'value',textStyle:{color: '#2b2b2b', fontName: 'Arial', fontSize: '10'}},
        colors:['#4393B5','#38A37A','#84D07C','#E2B66C','#E2937D','#DA5F6E','#B66483','#7B498F','#414F7B','#A7A7A7','#7CC7CE','#489A9D','#A4CEBB','#649644','#E0D152','#F1A628','#A3383A','#8C734D','#EA6394','#CE92C0','#5A78B1'],
//        colors:['#327FA0','#E2B66C','#DB7258','#A4B41E','#38A37A','#B66483','#7B498F','#414F7B'],
        pieSliceText: 'none',
        chartArea:{left:15,top:15,bottom:10,right:10,width:"80%",height:"80%"},
        pieSliceBorderColor:'white'

    }

    // Create and draw the visualization.
    var pieChart = new google.visualization.PieChart(document.getElementById(divNameId));
    pieChart.draw(data, options);

    if(catchClick){
        google.visualization.events.addListener(pieChart, 'select', selectHandler);
    }
    function selectHandler() {
        GS.tracking.sendOmnitureData('demographics');
        GS.tabManager.showTabWithOptions({tab:'demographics', hash:'header'});
    }
}

(function(){
    var drawChartFunc = function(){ drawPieChart(${chartParameters}) };
    if (GS_PieLoader) {
        GS_PieLoader.push(drawChartFunc);
    } else {
        google.setOnLoadCallback(drawChartFunc);
    }
})();