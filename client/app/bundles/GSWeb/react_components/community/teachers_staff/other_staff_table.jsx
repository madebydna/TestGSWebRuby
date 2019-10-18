import React from 'react';
import QuestionMarkToolTip from '../../school_profiles/question_mark_tooltip';
import { t } from '../../../util/i18n';

function OtherStaffTable ({ tooltip, data, name }) {
  const renderRow = (row, i) => {
    return (
      <div className="ts-row ts-row-narrow other-staff" key={`other_staff_${i}`}>
        <div className="ts-row-one-half-xs other-staff-label">
          {row.name}
          <QuestionMarkToolTip content={row.tooltip} className="tooltip" element_type="datatooltip"/>
          <span className="gray-heading">{t('State avg')}</span>
        </div>
        <div className="ts-row-one-quarter-xs">
          <div className="score-display">
            {row.full_time_district_value}
            <span className="gray-heading open-sans">{row.full_time_state_value}</span>
          </div>
        </div>
        <div className="ts-row-one-quarter-xs">
          <div className="score-display">
            {row.part_time_district_value}
            <span className="gray-heading open-sans">{row.part_time_state_value}</span>
          </div>
        </div>
      </div>
    );
  }


  return (
    <React.Fragment>
      <div className="ts-row ts-row-no-border">
        <div className="ts-row-one-half-xs rating-score-item-label">
          {name}
          <QuestionMarkToolTip content={tooltip} className="tooltip" element_type="datatooltip"/>
        </div>
      </div>
      <div className="ts-row ts-row-no-border ts-row-narrow other-staff">
        <div className="ts-row-one-half-xs">&nbsp;</div>
        <div className="ts-row-one-quarter-xs gray-heading">
          {t('teachers_staff.full-time')}
        </div>
        <div className="ts-row-one-quarter-xs gray-heading">
          {t('teachers_staff.part-time')}
        </div>
      </div>
      {data.map(renderRow)}
    </React.Fragment>
  );
}

export default OtherStaffTable;