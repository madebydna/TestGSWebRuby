import React from "react";
import PropTypes from "prop-types";
import { t } from "util/i18n";
import BasicDataModuleLayout from '../school_profiles/basic_data_module_layout';
import DataRow from './teachers_staff/data_row';
import InfoBox from 'react_components/school_profiles/info_box';
import QualarooDistrictLink from '../qualaroo_district_link';
import QuestionMarkToolTip from '../school_profiles/question_mark_tooltip';

const SummaryRating = ({ summaryRatingData, district }) => {

  const title = <div data-ga-click-label={summaryRatingData.title}>
    <h3>{summaryRatingData.title}</h3>&nbsp;
    <QuestionMarkToolTip content={summaryRatingData.tooltip} className="tooltip" element_type="datatooltip" />
  </div>

  const body = <div>
    <div className="auto-narration" dangerouslySetInnerHTML={{ __html: summaryRatingData.narration }} />
    <DataRow
      name={summaryRatingData.graphic_header}
      tooltip={summaryRatingData.graphic_header_tooltip}
      type={'pie_chart'}
      data={summaryRatingData.data}
      className={"ts-row-two-thirds-xs ts-row-full-md rating-score-item__label"}
    />
  </div>

  const footer = <div data-ga-click-label={null}>
    <InfoBox content={summaryRatingData.source} element_type="sources" pageType={'district'}>{t('See notes')}</InfoBox>
    <QualarooDistrictLink module={`district_${summaryRatingData.key}`}
      districtId={district.districtId} state={district.state} type='yes_no' />
  </div>

  return (
    <BasicDataModuleLayout
      id={summaryRatingData.key}
      className={summaryRatingData.key}
      // icon={icon}
      title={title}
      subtitle={summaryRatingData.subtext}
      csa_badge={false}
      body={body}
      footer={footer}
    />
  )
}

export default SummaryRating;