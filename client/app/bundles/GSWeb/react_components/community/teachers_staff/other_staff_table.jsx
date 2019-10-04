import React from 'react';
import QuestionMarkToolTip from '../../school_profiles/question_mark_tooltip';
import { t } from '../../../util/i18n';

class OtherStaffTable extends React.Component {
  renderRow(row, i) {
    return (
      <div className="ts-row ts-row--narrow other-staff" key={`other_staff_${i}`}>
        <div className="ts-row__one-half-xs other-staff-label">
          {row.name}
          <QuestionMarkToolTip content={row.tooltip} className="tooltip" element_type="datatooltip"/>
          <span className="gray-heading">{t('State avg')}</span>
        </div>
        <div className="ts-row__one-quarter-xs">
          <div className="score-display">
            {row.full_time_district_value}
            <span className="gray-heading open-sans">{row.full_time_state_value}</span>
          </div>
        </div>
        <div className="ts-row__one-quarter-xs">
          <div className="score-display">
            {row.part_time_district_value}
            <span className="gray-heading open-sans">{row.part_time_state_value}</span>
          </div>
        </div>
      </div>
    );
  }


  render() {
    return (
      <React.Fragment>
        <div className="ts-row ts-row--no-border">
          <div className="ts-row__one-half-xs rating-score-item__label">
            {this.props.name}
            <QuestionMarkToolTip content={this.props.tooltip} className="tooltip" element_type="datatooltip"/>
          </div>
        </div>
        <div className="ts-row ts-row--no-border ts-row--narrow other-staff">
          <div className="ts-row__one-half-xs">&nbsp;</div>
          <div className="ts-row__one-quarter-xs gray-heading">
            {t('teachers_staff.full-time')}
          </div>
          <div className="ts-row__one-quarter-xs gray-heading">
            {t('teachers_staff.part-time')}
          </div>
        </div>
        {this.props.data.map(this.renderRow)}
      </React.Fragment>
    );
  }
}

export default OtherStaffTable;