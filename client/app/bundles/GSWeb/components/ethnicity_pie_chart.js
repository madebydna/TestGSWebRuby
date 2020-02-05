import { getScript } from '../util/dependency';
import { t } from 'util/i18n';
// TODO: import $

      //  If you change these colors they need to be changed in _students.html.erb and/or students.jsx
  const ethnicityColors = ['#0f69c4', '#2bdc99', '#f1830f', '#f1e634', '#6f2eb4', '#ef60d0', '#ca3154', '#999EFF'];
      // write the graph to this location in html
  const ethnicityGraph = '#ethnicity-graph';

  const buildEthnicityDataFromGon = function (data, valueType) {
    const returnvalue = [];
    data.forEach((value,index)=>{
      returnvalue.push({
        name: value.breakdown,
        legendIndex: index,
        y: Math.round(value[`${valueType}_value`]),
        color: ethnicityColors[index]
      });
    });
    return returnvalue;
  };

  const generateEthnicityChart = function (data, valueType = 'school') {
    if (data.length > 0) {
      const callback = function () {
        const chart = document.querySelector(ethnicityGraph);
        let chart_height = 400;

        if (chart.offsetWidth < 400) {
          chart_height = chart.offsetWidth - 40;
        }
        const ethnicityData = buildEthnicityDataFromGon(data, valueType);

        const ethnicityChartForHighlight = Highcharts.chart(chart, {
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
                val = Math.round(this.percentage);
              }
              return '<span style="color:' + this.color + `;">\u25CF</span> ${t('percentage')}: <b>` + val + '</b>';
            }
          },
          series: [{
            name: 'percentage',
            data: ethnicityData
          }]
        });

        const highlightSlice = function(){
          const sliceId = this.dataset.sliceId;
          if (typeof (sliceId) !== 'undefined' && ethnicityChartForHighlight.series[0].data[sliceId]) {
            ethnicityChartForHighlight.series[0].data[sliceId].select();
          }
        };
        document.querySelectorAll('.js-highlightPieChart').forEach(selector=>{
          selector.addEventListener('mouseover', highlightSlice);
          selector.addEventListener('mouseout', highlightSlice);
        });
      };

      if(window.Highcharts) {
        callback();
      } else {
        getScript(gon.dependencies.highcharts).done(callback);
      }
    }
  };

  export { generateEthnicityChart };
