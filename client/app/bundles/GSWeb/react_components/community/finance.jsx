import React from 'react';
import { t } from "util/i18n";
import spending from 'icons/spending.svg';
import ParentTip from '../school_profiles/parent_tip';
import BasicDataModuleLayout from '../school_profiles/basic_data_module_layout';
import InfoBox from 'react_components/school_profiles/info_box';
import QualarooDistrictLink from '../qualaroo_district_link';
import DataRow from './teachers_staff/data_row';
import ReactDOMServer from 'react-dom/server';

const Finance = ({dataValues, district}) => {
  const financeDataValues = dataValues.map(item => <DataRow key={item.name} {...item} />)

  const title = <div data-ga-click-label={t('finance.module_title')}>
    <h3>{t('finance.module_title')}</h3>
  </div>

  const icon = <div className="circle-rating--equity-blue">
      <img height='50px' src={spending} />
    </div>;

  const body = <div>
    <ParentTip><span dangerouslySetInnerHTML={{__html: t('finance.parent_tip')}}/></ParentTip>
    {financeDataValues}
  </div>;

  const sourcesContent = <div className='sourcing'>
     <h1>{t('district_data_sources_and_info')}</h1>
     {dataValues.map(dataValue =>{
       if (dataValue.data){
         return dataValue.data.map(subdata => <div key={subdata.source.name}>
             <h4>{subdata.source.name}</h4>
             <p>{subdata.source.description}</p>
             <p>{subdata.source.source_and_year}</p>
           </div>
         );
       }else{
         return <div key={dataValue.source.name}>
           <h4>{dataValue.source.name}</h4>
           <p>{dataValue.source.description}</p>
           <p>{dataValue.source.source_and_year}</p>
         </div>
       }
     })}
   </div>;

  const _sources = ReactDOMServer.renderToStaticMarkup(sourcesContent);

  const footer = <div data-ga-click-label={null}>
    <InfoBox content={_sources} element_type="sources" pageType={'district'}>{t('See notes')}</InfoBox>
    <QualarooDistrictLink module='district_finance'
      districtId={district.district_id} state={district.state} type='yes_no' />
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
      footer={footer}
    />
  )
}

export default Finance;