import React from "react";
import PropTypes from "prop-types";
import { t } from "util/i18n";
import BasicDataModuleLayout from '../school_profiles/basic_data_module_layout';
import DataRow from './teachers_staff/data_row';
import InfoBox from 'react_components/school_profiles/info_box';
import QualarooDistrictLink from '../qualaroo_district_link';
import QuestionMarkToolTip from '../school_profiles/question_mark_tooltip';

const GrowthRating = ({ growthData, district}) => {

  const title = <div data-ga-click-label={growthData.title}>
    <h3>{growthData.title}</h3>&nbsp;
    <QuestionMarkToolTip content={growthData.tooltip} className="tooltip" element_type="datatooltip" />
  </div>

  const body = <div>
    <div className="auto-narration" dangerouslySetInnerHTML={{ __html: growthData.narration }} />
    <DataRow
      name={growthData.graphic_header}
      tooltip={growthData.graphic_header_tooltip}
      type={'pie_chart'}
      data={growthData.data}
    />
  </div>

  const footer = <div data-ga-click-label={null}>
    <InfoBox content={growthData.source} element_type="sources" pageType={'district'}>{t('See notes')}</InfoBox>
    <QualarooDistrictLink module={`district_${growthData.key}`}
      districtId={district.districtId} state={district.state} type='yes_no' />
  </div>
  
  return (
    <BasicDataModuleLayout
      id={growthData.key}
      className={growthData.key}
      // icon={icon}
      title={title}
      subtitle={growthData.subtext}
      csa_badge={false}
      body={body}
      footer={footer}
    />
  )
}

export default GrowthRating;