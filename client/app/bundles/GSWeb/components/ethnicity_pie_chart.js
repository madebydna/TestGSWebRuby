import { getScript } from '../util/dependency';
// TODO: import $

      //  If you change these colors they need to be changed in _ethnicity.html.erb 
  const ethnicityColors = ['#184a7d', '#2ba3dc', '#08c569', '#dca21a', '#d94373', '#fdda46', '#0e6ac9', '#999EFF'];
      // write the graph to this location in html
  const ethnicityGraph = '#ethnicity-graph';

  const buildEthnicityDataFromGon = function (data) {
    var returnvalue = [];
    $.each(data, function (index, value) {
      returnvalue.push({
        name: value['breakdown'],
        legendIndex: index,
        y: Math.round(value['school_value']),
        color: ethnicityColors[index]
      });
    });
    return returnvalue;
  };

  const generateEthnicityChart = function (data) {
    if (data) {
      var callback = function () {
        var chart = $(ethnicityGraph);
        var chart_height = 400;
        if(chart.width() < 400) {
          chart_height = chart.width() - 40;
        }
        var ethnicityData = buildEthnicityDataFromGon(data);
        chart.highcharts({

          chart: {
            type: 'pie',
            height: chart_height
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
        getScript(gon.dependencies['highcharts']).done(callback);
      }
    }
  };

  export { generateEthnicityChart };
