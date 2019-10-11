import React from 'react';
import Highcharts from 'highcharts';
import HighchartsReact from 'highcharts-react-official';

const PieChartHighcharts = ({options}) => {

  const data = options.map((datum,idx) => (
    {
      name: datum.name,
      y: datum.value,
      legendIndex: idx,
      color: datum.color
    }
  ));
  
  const chartOptions = {
    chart: {
      plotBackgroundColor: null,
      plotBorderWidth: null,
      plotShadow: false,
      type: 'pie',
      height: 250
    },
    title: {
      text: options.title ? `${options.title}` : null
    },
    tooltip: {
      pointFormatter: function(){
        return `<span style="color: ${this.color} ;">\u25CF</span> percentage: <b> ${Math.floor(this.percentage)}% </b>`;
      }
    },
    plotOptions: {
      pie: {
        allowPointSelect: true,
        cursor: 'pointer',
        innerSize: 30,
        depth: 45,
        minSize: 130,
        animation:{
          duration: 1000
        },
        dataLabels: {
          enabled: true,
          formatter: function(){
            return Math.round(this.percentage) + '%'
          }
        },
        showInLegend: false
      }
    },
    credits: false,
    series: [{
      // name: 'Brands',
      colorByPoint: true,
      data: data
    }]
  }

  return(
    <div className="col-xs-12 col-sm-7">
      <HighchartsReact
        highcharts={Highcharts}
        options={chartOptions}
      />
    </div>
  )
  
}

export default PieChartHighcharts;

