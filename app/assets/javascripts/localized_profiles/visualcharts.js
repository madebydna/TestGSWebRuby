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

GS.visualchart = GS.visualchart || function($) {

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
        // TODO: need to track omniture data?
    };
    var colors = ['#339cc1','#66b5d1','#ffc550','#c9614f','#e8715d','#f19150','#69bd8d','#5fcbc8','#5f83a7','#c4d76b','#77b671','#71b2b2','#78778f','#a48683','#b2718e','#bd726a'];

//    var colors = ['#0083b2','#66b5d1','#99cde0','#CCE6F0','#ffb725','#ffd173','#38137a','#84d07c','#ff9326','#ffbe7d','#A7A7A7','#7CC7CE','#489A9D','#A4CEBB','#649644','#E0D152','#F1A628','#A3383A','#8C734D','#EA6394','#CE92C0','#5A78B1'];

    var drawPieChart = function(dataIn, divId, selectHandler, options, chartname) {
        var func = function() {
            var domNode = document.getElementById(divId);
            // If the dom node that the chart wants to fill is not on the page, just early exit
            if(domNode == null) {
                return false;
            }

            // Create and populate the data table.
            var data = google.visualization.arrayToDataTable(dataIn, true);
            $("#"+divId).css("width", GS.window.sizing.pieChartWidth(chartname));
            var defaultOptions = {
                width: GS.window.sizing.pieChartWidth(chartname),
                height: GS.window.sizing.pieChartHeight(chartname),
                legend: GS.window.sizing.pieChartLegend(chartname),
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
                chartArea:{left:15,top:15,bottom:10,right:10,width:"90%",height:"90%"},
                pieSliceBorderColor:'white'

            };

            $.extend(true, defaultOptions, options);

            // Create and draw the visualization.
            var pieChart = new google.visualization.PieChart(domNode);
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

    var drawBarChartTestScoresStacked = function (barChartData, divId, chartname) {
      var func = function () {
        var domNode = document.getElementById(divId);
        // If the dom node that the chart wants to fill is not on the page, just early exit
        if(domNode == null) {
          return false;
        }

        var dataTable = new google.visualization.DataTable();

        dataTable.addColumn('string', 'year');
        dataTable.addColumn('number', 'Proficient');
        dataTable.addColumn({'type': 'string', 'role': 'annotation'});
        dataTable.addColumn({'type': 'string', 'role': 'tooltip', 'p': {'html': true}});
        dataTable.addColumn('number', 'Advanced');
        dataTable.addColumn({'type': 'string', 'role': 'annotation'});
        dataTable.addColumn({'type': 'string', 'role': 'tooltip', 'p': {'html': true}});

        dataTable.addRows(barChartData);

        $("#"+divId).css("width", GS.window.sizing.barChartWidth(chartname));
        var defaultOptions = {
          width: GS.window.sizing.barChartWidth(chartname),
          height: GS.window.sizing.barChartHeight(chartname),
          legend: { position: GS.window.sizing.barChartLegend(chartname) },
          tooltip: { isHtml: true },
          colors: colors,
          hAxis: { maxValue: '100', minValue:'0' },
          chartArea: { left:'50',top:'20', width: GS.window.sizing.barChartAreaWidth(chartname), height:"60%" },
          isStacked:true
        };

        var chart = new google.visualization.BarChart(domNode);
        chart.draw(dataTable, defaultOptions);

      };
      if (loader) {
        loader.push(func);
      } else {
        google.setOnLoadCallback(func);
      }

    };

    var drawBarChartTestScores = function (barChartData, divId, chartname) {
        var func = function () {
            var domNode = document.getElementById(divId);
            // If the dom node that the chart wants to fill is not on the page, just early exit
            if(domNode == null) {
                return false;
            }

            var dataTable = new google.visualization.DataTable();
            //The 3rd and the 5th columns are used for tool tips.
            dataTable.addColumn('string', 'year');
            dataTable.addColumn('number', 'This school');
            dataTable.addColumn({'type': 'string', 'role': 'annotation'});
            dataTable.addColumn({'type': 'string', 'role': 'tooltip', 'p': {'html': true}});

            dataTable.addRows(barChartData);

            $("#"+divId).css("width", GS.window.sizing.barChartWidth(chartname));
            var defaultOptions = {
                width: GS.window.sizing.barChartWidth(chartname),
                height: GS.window.sizing.barChartHeight(chartname),
                legend: {position: GS.window.sizing.barChartLegend(chartname)},
                tooltip: { isHtml: true },
                colors: colors,
                hAxis: {maxValue: '100', minValue:'0'},
                chartArea: {left:'50',top:'20', width: GS.window.sizing.barChartAreaWidth(chartname), height:"60%"}
            };

            var chart = new google.visualization.BarChart(domNode);
            chart.draw(dataTable, defaultOptions);

        };
        if (loader) {
            loader.push(func);
        } else {
            google.setOnLoadCallback(func);
        }

    };

    var drawBarChartReviews = function (barChartData, div, options) {
        var func = function () {
            var domNode = document.getElementById(div);

            if (domNode != null) {
                var data = google.visualization.arrayToDataTable(barChartData);
                var chart = new google.visualization.BarChart(domNode);
                chart.draw(data, options);
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
        drawBarChartTestScores: drawBarChartTestScores,
        drawBarChartTestScoresStacked: drawBarChartTestScoresStacked,
        drawBarChartReviews:drawBarChartReviews,
        loader: loader
    }

}(jQuery);
