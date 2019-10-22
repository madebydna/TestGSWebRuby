import React, { useState, useEffect } from 'react';
import Highcharts from 'highcharts';
import HighchartsReact from 'highcharts-react-official';
import { t } from 'util/i18n';

const PieChartHighcharts = ({ options, slicedIdx}) => {
  const data = options.map((datum,idx) => {
    let sliced;
    if (idx === slicedIdx){
      sliced = true;
    }
    
    return {
      name: datum.name,
      y: datum.value,
      legendIndex: idx,
      color: datum.color,
      sliced: sliced
    }
  });

  useEffect(()=>{
    setpieChartOptions(initialOptions)
  }, [slicedIdx])
  
  const initialOptions = {
    chart: {
      plotBackgroundColor: null,
      plotBorderWidth: null,
      plotShadow: false,
      type: 'pie',
      height: 250
    },
    title: {
      text: null
    },
    tooltip: {
      pointFormatter: function(){
        return `<span style="color: ${this.color} ;">\u25CF</span> ${t('percentage')}: <b> ${Math.floor(this.percentage)}% </b>`;
      }
    },
    plotOptions: {
      pie: {
        allowPointSelect: true,
        cursor: 'pointer',
        innerSize: 30,
        depth: 45,
        minSize: 130,
        size: '75%',
        animation:{
          duration: 1000
        },
        dataLabels: {
          enabled: true,
          formatter: function(){
            return Math.round(this.percentage) + '%';
          },
          distance: 10
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

  const [pieChartOptions, setpieChartOptions] = useState(initialOptions)

  return(
    <div className="col-xs-12 col-sm-7">
      <HighchartsReact
        highcharts={Highcharts}
        // highcharts={window.Highcharts}
        options={pieChartOptions}
      />
    </div>
  )
  
}

export default PieChartHighcharts;

