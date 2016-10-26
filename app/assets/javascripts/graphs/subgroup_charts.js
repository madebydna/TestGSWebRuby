var GS = GS || {}
GS.graphs = GS.graphs || {};
GS.graphs.subgroupCharts = GS.graphs.subgroupCharts || (function($) {
  //
  var subgroupSliceColor = '#34A4DA';
  var defaultPieColor = '#eef3f5';
  var titleMap = {
    'students-participating-in-free-or-reduced-price-lunch-program': 'Students from low income familes',
    'english-learners': 'Students learning english'
  };

  var buildSubgroupData = function (parsedData) {
    var otherValue = 100 - parseFloat(parsedData.schoolValueFloat);
    var subgroupData = [
      {
        name: parsedData.name, 
        y:parsedData.schoolValueFloat,
        color: subgroupSliceColor
      },
      {
        name:'Other',
        y:otherValue,
        color: defaultPieColor
      }
    ]
    return subgroupData;
  };

  var subgroupNameToChartId = function(subgroupName) {
    return subgroupName.toLowerCase().replace(/ /g,'-');
  };

  var parseCharacteristicsCache = function(data, key) {
    var cacheData = data[0];
    if (! cacheData ) {
      return null;
    }
    var schoolValue = cacheData['school_value'];
    var schoolValuePercent = Math.round(schoolValue).toString() + '%';
    var chartId = subgroupNameToChartId(key);
    var chartTitle = titleMap[chartId];
    parsedData = {
      name: key,
      chartId: chartId,
      chartTitle: chartTitle,
      schoolValueFloat: schoolValue,
      stateAverage: cacheData['state_average_2012'].toString() + '%',
      schoolValuePercent: schoolValuePercent
    };

    if (validParsedData(parsedData)) {
      return parsedData;
    } else {
      return null;
    }
  };

  var validParsedData = function (parsedData) {
    var values =  _.values(parsedData)
    var missingValues = _.remove(values, function(v) {
      return !v;
    });
    return missingValues.length == 0;
  };

  var generateSubgroupContainer = function(parsedData) {
    var containerHtml = "<div class='subgroup col-xs-6 col-md-4'><div class='title'>" + parsedData.chartTitle + "</div><div id='" + parsedData.chartId + "'></div><div class='state-avg'>State avg. " + parsedData.stateAverage +  "</div></div>";
    $('.subgroups > .row').append(containerHtml);
  };

  var renderChart = function(data, key) {
    var parsedData = parseCharacteristicsCache(data, key);
    if ( ! parsedData) {
      return null;
    }
    var subgroupData = buildSubgroupData(parsedData);
    generateSubgroupContainer(parsedData);
    var chart = new Highcharts.Chart({
      chart: {
        renderTo: parsedData.chartId,
        type: 'pie',
        height: '140',
        spacing: [10,10,0,10]
      },
      credits: {
        enabled: false
      },
      title: {
        text: parsedData.schoolValuePercent,
        verticalAlign: 'middle',
        floating: true,
        y: 5
      },
      tooltip: {
        enabled: false
      },
      plotOptions: {
        series: {
          states: {
            hover: {
              enabled: false
            }
          }
        },
        pie: {
          innerSize: '63%',
          dataLabels: {
            enabled: false
          },
        }
      },
      series: [{
        data: subgroupData
      }]
    });
  };

  var generateSubgroupPieCharts = function () {
    if (gon.subgroup) {
      var subgroupData = gon.subgroup;
      var callback = function() {
        _.forOwn(subgroupData, renderChart);
      };
      if(window.Highcharts) {
        callback();
      } else {
        $.cachedScript("https://code.highcharts.com/highcharts.js").done(callback);
      }
    }
  };

  return {
    generateSubgroupPieCharts: generateSubgroupPieCharts
  };
})(jQuery);
