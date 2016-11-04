var GS = GS || {}
GS.graphs = GS.graphs || {};
GS.graphs.ethnicityPieChart = GS.graphs.ethnicityPieChart || (function($) {
      //  If you change these colors they need to be changed in _ethnicity.html.erb 
  var ethnicityColors = ['#184a7d', '#2ba3dc', '#08c569', '#dca21a', '#d94373', '#fdda46', '#0e6ac9', '#999EFF'];
      // write the graph to this location in html
  var ethnicityGraph = '#ethnicity-graph';

  var buildEthnicityDataFromGon = function () {
    var returnvalue = [];
    $.each(gon.ethnicity, function (index, value) {
      returnvalue.push({
        name: value['breakdown'],
        legendIndex: index,
        y: Math.round(value['school_value']),
        color: ethnicityColors[index]
      });
    });
    return returnvalue;
  };

  var generateEthnicityChart = function () {
    if (gon.ethnicity) {
      var callback = function () {
        var ethnicityData = buildEthnicityDataFromGon();
        $(ethnicityGraph).highcharts({
          chart: {
            type: 'pie'
          },
          title: {
            text: null
          },
          credits: {
            enabled: false
          },
          plotOptions: {
            pie: {
              innerSize: 90,
              depth: 45
            },
            series: {
              dataLabels: {
                enabled: true,
                formatter: function () {
                  if(this.percentage < 1){
                    return '<1%';
                  }
                  return Math.round(this.percentage) + '%';
                },
                distance: 15
              }
            }
          },
          tooltip: {
            pointFormatter: function() {
              var val;
              if (this.percentage < 1) {
                val = "<1";
              } else {
                val = Math.round(this.percentage)
              }
              return '<span style="color:' + this.color + ';">\u25CF</span> percentage: <b>' + val + '</b>';
            }
          },
          series: [{
            name: 'percentage',
            data: ethnicityData
          }]
        });
        var ethnicityChartForHighlight = $(ethnicityGraph).highcharts();
        $('.js-highlightPieChart').on("mouseenter mouseleave", function(){
          sliceId = $(this).data('slice-id');
          ethnicityChartForHighlight.series[0].data[sliceId].select();
        });
      };

      if(window.Highcharts) {
        callback();
      } else {
        GS.dependency.getScript("/assets/highcharts.js").done(callback);
      }
    }
  };
  return {
    generateEthnicityChart: generateEthnicityChart
  };
})(jQuery);
