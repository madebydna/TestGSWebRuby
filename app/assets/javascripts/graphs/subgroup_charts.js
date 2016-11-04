var GS = GS || {}
GS.graphs = GS.graphs || {};
GS.graphs.subgroupCharts = GS.graphs.subgroupCharts || (function($) {
  //
  var subgroupSliceColor = '#34A4DA';
  var defaultPieColor = '#eef3f5';
  var colorMap = {
    'Female': '#21C36C',
    'Male': '#34A4DA'
  }
  var titleMap = {
    'students-participating-in-free-or-reduced-price-lunch-program': 'Students from low-income familes',
    'english-learners': 'Students learning English'
  };

  var infoTextMap = {
    'students-participating-in-free-or-reduced-price-lunch-program': 'The students from low-income families designation is based on the percentage of students at this school who are eligible for free or reduced-price lunch.',
    'english-learners': 'This group includes all students classified as English language learners.'
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
        name: 'Other',
        y: otherValue,
        color: defaultPieColor
      }
    ]
    return subgroupData;
  };

  var buildGenderData = function(parsedGenderData) {
    var genderData = _.map(parsedGenderData, function(data) {
      var returnValue = {
        name: data.name,
          y: data.schoolValueFloat,
          color: colorMap[data.name]
      };
      return returnValue;
    })
    return genderData;
  }

  var subgroupNameToChartId = function(subgroupName) {
    return subgroupName.toLowerCase().replace(/ /g,'-');
  };

  var parseGenderCharacteristicsData = function(genderData) {
    var validParsedGenderData = true;
    var parsedGenderData = [];
   _.forOwn(genderData, function (data, key) {
     var parsedData = parseCharacteristicsCache(data, key)
     if (! validParsedData(parsedData) ) {
        validParsedGenderData = null;
     }
     parsedGenderData.push(parsedData);
   });
     if ( validParsedGenderData && parsedGenderData.length > 0 ) {
       return parsedGenderData;
     } else {
      return null;
     }
  };

  var parseCharacteristicsCache = function(data, key) {
    var cacheData = data[0];
    if (! cacheData ) {
      return null;
    }
    var schoolValue = cacheData['school_value'];
    var schoolValuePercent = Math.round(schoolValue).toString() + '%';
    parsedData = {
      name: key,
      schoolValueFloat: schoolValue,
      // stateAverage: cacheData['state_average_2012'].toString() + '%',
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
    var stateAvgHtml = "";
    if (parsedData.stateAverage) {
      stateAvgHtml =  "<div class='state-avg'>State avg. " + parsedData.stateAverage +  "</div>";
    }
    var containerHtml = "<div class='subgroup col-xs-6 col-sm-4 col-md-6 col-lg-4'><div class='title'> " + parsedData.chartTitle + generateInfoCircle(parsedData.infoText) +  "</div><div id='" + parsedData.chartId + "'></div>" + stateAvgHtml + "</div>";
    $('.subgroups > .row').append(containerHtml);
  };

  generateInfoCircle = function(content) {
   var infoCircleHtml =  ' <a data-remodal-target="modal_info_box" data-content-type="info_box" data-content-html="' + content  +  '" class="gs-tipso info-circle" href="javascript:void(0)">I</a>'
    return infoCircleHtml;
  }

  var generateGenderContainer = function(parsedGenderData) {
    var chartTitle = 'Gender';
    var chartId = 'gender';
    var containerHtml = "<div class='subgroup col-xs-6 col-sm-4 col-md-6 col-lg-4'><div class='title gender'>" + chartTitle + "</div><div id='" + chartId + "'></div></div>";
    $('.subgroups > .row').append(containerHtml);
  }

  var renderGenderChart = function(data, key) {
    var parsedGenderData = parseGenderCharacteristicsData(data, key);
    if ( ! parsedGenderData) {
      return null;
    }
    var genderData = buildGenderData(parsedGenderData);
    generateGenderContainer(parsedGenderData);
    var chartId = 'gender';
    var chart = new Highcharts.Chart({
      chart: {
        renderTo: chartId,
        type: 'pie',
        height: '175',
        spacing: [10,10,10,10],
        margin: [10,5,30,5]
      },
      credits: {
        enabled: false
      },
      legend: {
        enabled: true,
        itemDistance: 2,
        margin: 0
      },
      title: {
        text: null
      },
      tooltip: {
        enabled: false
      },
      plotOptions: {
        series: {
          states: {
            hover: {
              enabled:false
            }
          },
        },
        pie: {
          innerSize: '33%',
          dataLabels: {
            enabled: true,
            formatter: function () {
              return "<div class='open-sans'>" + Math.round(this.percentage) + "%</div>";
            },
            color: 'black',
            useHTML: true,
            style: {
              fontSize: '14px',
              textShadow: false,
              fontWeight: "regular"
            },
            distance: -20,
          },
          allowPointSelect: false,
          minSize: 140,
          showInLegend: true,
          point: {
            events: {
              legendItemClick: function () {
                console.log('d');
                return false; // <== returning false will cancel the default action
              }
            }
          }
        }
      },
      series: [{
        name: 'percentage',
        data: genderData
      }]
    });
  };

  var renderSubgroupChart = function(data, key) {
    var parsedData = parseCharacteristicsCache(data, key);
    if ( ! parsedData) {
      return null;
    }
    parsedData.chartId = subgroupNameToChartId(parsedData.name);
    parsedData.chartTitle = titleMap[parsedData.chartId];
    parsedData.infoText = infoTextMap[parsedData.chartId];
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
      $.cachedScript("https://code.highcharts.com/highcharts.js").done(function () {
        _.forOwn(subgroupData, renderSubgroupChart);
        if (gon.gender) {
          var genderData = gon.gender;
          renderGenderChart(genderData);
          GS.tooltip.initialize();
        }
      });
    }
  };

  return {
    generateSubgroupPieCharts: generateSubgroupPieCharts
  };
})(jQuery);
