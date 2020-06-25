import React from 'react';
import PropTypes from 'prop-types';
import { t } from '../../util/i18n';
import QuestionMarkTooltip from '../school_profiles/question_mark_tooltip';
import CircleCheck from '../icons/circle_check';
import CircleDash from '../icons/circle_dash';
import CircleX from '../icons/circle_x';

const Circle = (props) => {
  const { breakdown, tooltip_html, value } = props;

  const renderCircle = () => {
    if (value === 'All' || value === 'Yes' || value === 'Partner') {
      return (
        <div className="circle-viz">
          <CircleCheck key={breakdown} />
        </div>
      );
    } else if (value === 'Partial') {
      return (
        <div className="circle-viz">
          <CircleDash key={breakdown} />
          <div className="state-average tar">{t('distance_learning.ratings.not_all_grades')}</div>
        </div>
      );
    } else if (value === "N/A") {
      return (
        <div className="circle-viz">
          <div className="tar">N/A</div>
        </div>
      );
    } else {
      return (
        <div className="circle-viz">
          <CircleX key={breakdown} />
        </div>
      );
    }
  };

  return <div className="row bar-graph-display">
    <div className="test-score-container clearfix circle-viz-row-container">
      <div className="col-xs-9 col-sm-6 subject">
        {breakdown}&nbsp;{tooltip_html && <QuestionMarkTooltip content={tooltip_html} className="tooltip" element_type="datatooltip" />}
      </div>
      <div className="col-xs-1 col-sm-1" />
      <div className="col-xs-2 col-sm-5">
        {renderCircle()}
      </div>
    </div>
  </div>
}

Circle.propTypes = {
  breakdown: PropTypes.string.isRequired,
  tooltip_html: PropTypes.string,
  value: PropTypes.string.isRequired
};

export default Circle;
