import React from 'react';
import { t } from "util/i18n";
import spending from 'icons/spending.svg';
import ParentTip from '../school_profiles/parent_tip';
import BasicDataModuleLayout from '../school_profiles/basic_data_module_layout';
import DataRow from './teachers_staff/data_row';
import PieChartDataRow from './pie_chart_data_row';
import PieChartHighCharts from '../pie_chart_highcharts';

const Finance = ({props}) => {
  const title = <div data-ga-click-label={t('finance.module_title')}>
    <h3>{t('finance.module_title')}</h3>
  </div>

  const icon = <div className="circle-rating--equity-blue">
      <img height='50px' src={spending} />
    </div>;

  const revenues = props.revenue.map(item => <DataRow {...item} />)

  const expenditures = props.expenditure.map(item => <DataRow {...item} />)

  const colors = ['#0f69c4', '#2bdc99', '#f1830f', '#f1e634', '#6f2eb4', '#ef60d0', '#ca3154', '#999EFF'];

  const revenuePieChart = props.revenue_sources.map((source,idx) => {
    return {name: source.name, value: source.district_value, color: colors[idx]}
  });

  const expenditurePieChart = props.expenditure_sources.map((source, idx) => {
    return { name: source.name, value: source.district_value, color: colors[idx] }
  })

  const options = {
    data: revenuePieChart
  }

  const expOptions = {
    data: expenditurePieChart
  }

  const body = <div>
    <ParentTip><span dangerouslySetInnerHTML={{__html: t('finance.parent_tip')}}/></ParentTip>
    {revenues}
    <PieChartDataRow 
      options={options} 
      name={t('finance.Revenue sources')}
      tooltip={t('finance.revenue_tooltip')}
    />
    {expenditures}
    <PieChartDataRow 
      options={expOptions} 
      name={t('finance.Spending by category')}
      tooltip={t('finance.expenditure_tooltip')}
    />
  </div>
   
  
  return (
    <BasicDataModuleLayout
      id="finance"
      className="finance"
      icon={icon}
      title={title}
      subtitle={t('finance.module_subtitle')}
      csa_badge={false}
      body={body}
      footer={null}
    />
  )
}

export default Finance;