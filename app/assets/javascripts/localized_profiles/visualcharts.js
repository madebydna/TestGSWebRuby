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

    var colors = ['#69b684','#6cbfb5','#fcc769','#e7715d','#ef975b','#c4d66b','#86b16f','#7a6f8d','#af698c','#c9614f','#a9816a','#6f95b5','#78778f','#a48683','#b2718e','#bd726a'];

    var drawPieChart = function(dataIn, divId, selectHandler, options, chartname) {
        var func = function() {
            var domNode = document.getElementById(divId);
            // If the dom node that the chart wants to fill is not on the page, just early exit
            if(domNode == null) {
                return false;
            }

            var dataTable = new google.visualization.DataTable();

            dataTable.addColumn('string', 'Label');
            dataTable.addColumn('number', 'Value');
            dataTable.addColumn({'type': 'string', 'role': 'tooltip', 'p': {'html': true}});

            dataTable.addRows(dataIn);

            // Create and populate the data table.
//            var data = google.visualization.arrayToDataTable(dataIn, true);
            $("#"+divId).css("width", GS.window.sizing.pieChartWidth(chartname));
            var defaultOptions = {
                width: GS.window.sizing.pieChartWidth(chartname),
                height: GS.window.sizing.pieChartHeight(chartname),
                legend: GS.window.sizing.pieChartLegend(chartname),
//                tooltip: { isHtml: true },
                tooltip: { trigger: 'focus', text: 'value', showColorCode: 'true'},
                colors: colors,
                pieSliceText: 'none',
                chartArea:{left:15,top:15,bottom:10,right:10,width:"90%",height:"90%"},
                pieSliceBorderColor:'white'

            };

            $.extend(true, defaultOptions, options);

            // Create and draw the visualization.
            var pieChart = new google.visualization.PieChart(domNode);
            pieChart.draw(dataTable, defaultOptions);

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
            dataTable.addColumn('number', 'Proficient or better');
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

    var drawBarChart = function(barChartData, domId, chartname, barLabels) {
        var func = function () {
            var domNode = document.getElementById(domId);
            // If the dom node that the chart wants to fill is not on the page, just early exit
            if(domNode == null) {
                return false;
            }

            var dataTable = new google.visualization.DataTable();
            //The 3rd and the 5th columns are used for tool tips.

            var numberOfBars = barLabels.length;
            dataTable.addColumn('string', 'data point');
            for(var i = 0; i < numberOfBars; i++) {
              dataTable.addColumn('number', barLabels[i]);
              dataTable.addColumn({'type': 'string', 'role': 'annotation'});
              dataTable.addColumn({'type': 'string', 'role': 'tooltip', 'p': {'html': true}});
            }

            dataTable.addRows(barChartData);

            $("#"+domId).css("width", GS.window.sizing.barChartWidth(chartname));
            var defaultOptions = {
                width: GS.window.sizing.barChartWidth(chartname),
                height: GS.window.sizing.barChartHeight(chartname),
                legend: {position: GS.window.sizing.barChartLegend(chartname)},
                tooltip: { isHtml: true },
                colors: colors,
                hAxis: {maxValue: '100', minValue:'0'},
                chartArea: {
                  left: GS.window.sizing.barChartLabelWidth(chartname),
                  top:'20',
                  width: GS.window.sizing.barChartAreaWidth(chartname),
                  height:"60%"
                }
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

    var drawBarChartReviews = function (barChartData, div) {
        var func = function () {
          var options = {
            colors: colors,
            legend:{
              position: 'none'
            },
            hAxis:{
              title: 'Ratings Distribution',
              titleTextStyle:{
                fontName: 'Arial',
                fontSize: 12,
                italic: false
              },
              textStyle:{
                fontName: 'Arial',
                fontSize: 12,
                italic: false
              }
            },
            vAxis:{
              textStyle:{
                fontName: 'Arial',
                fontSize: 12,
                italic: false
              }
            },
            width:250,
            height:130,
            chartArea:{
              top:0
            }
          };
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
        drawBarChart: drawBarChart,
        drawBarChartTestScores: drawBarChartTestScores,
        drawBarChartTestScoresStacked: drawBarChartTestScoresStacked,
        drawBarChartReviews:drawBarChartReviews,
        loader: loader
    }

}(jQuery);
