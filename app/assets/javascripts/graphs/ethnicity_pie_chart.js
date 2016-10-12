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
    console.log("I am here");
    if (gon.ethnicity) {
      $.cachedScript("https://code.highcharts.com/highcharts.js").done(function () {
        var ethnicityData = buildEthnicityDataFromGon();
        $(ethnicityGraph).highcharts({
          chart: {
            type: 'pie'
          },
          title: {
            text: null
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
                  return Math.round(this.percentage) + ' %';
                },
                distance: 15
              }
            }
          },
          series: [{
            name: 'percentage',
            data: ethnicityData
          }]
        });
      });
    }
  };
  return {
    generateEthnicityChart: generateEthnicityChart
  };
})(jQuery);