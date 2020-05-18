import React from 'react';
import PropTypes from 'prop-types';
import { parse, extract } from 'query-string';
import QuestionMarkTooltip from './question_mark_tooltip';
import { analyticsEvent } from 'util/page_analytics';
import { t } from '../../util/i18n';
import { getQueryParam, updateUrlParameter } from 'components/header/query_param_utils';

// TODOs:
// - rename subject css class
// - rename bar-graph-container css class
// - improve renderStudentPercentage

const BasicDataModuleRow = ({
  breakdown,                // The short text description of the data type
  label,                    // The text version of the score/value
  percentage,               // The percentage of study body
  display_percentages,      // Whether or not to display % of student body
  number_students_tested,   // Absolute number of students the score applies to
  children,                 // A visualization to put into this container
  drawerTrigger,            // Any node which when clicked will open drawer
  tooltip_html,              // String containing html, to place inside tooltip to right of label
  link                      // Displayed in place of drawerTrigger, if it exists
}) => {


  const renderStudentPercentage = function(){
    if(display_percentages){
      if(percentage == '200' || breakdown == 'All students' || breakdown == 'Todos los estudiantes'){
        if(number_students_tested > 0) {
          return <span className="subject-subtext"> <br className="br_except_for_mobile" />({number_students_tested.toLocaleString()} {t('students')})</span>
        }
      }
      else {
        if (percentage > 0) {
          return <span className="subject-subtext"> <br className="br_except_for_mobile" />({percentage}{t('percentage of students')})</span>
        }
      }
    }
  }

  const handleClick = (compareLink) => {
    const parsedQueryString = parse(extract(compareLink));
    const ethnicity = parsedQueryString.breakdown;
    const { state, id } = window.gon.school;
    analyticsEvent('Profile', 'CompareSchool', `${id}:${state}:race-ethnicity:${ethnicity}`);
  };

  const renderCompareLink = () => {
    if (getQueryParam('lang') === 'es') {
      link = updateUrlParameter(link, 'lang', 'es');
    }
    return <a onClick={()=> handleClick(link)} rel="nofollow" className="anchor-button" href={link}>Compare</a>
  }
  return (
    <div className="row bar-graph-display">
      <div className="test-score-container clearfix">
        <div className="col-xs-12 col-sm-5 subject">
          {breakdown}&nbsp;{ tooltip_html && <QuestionMarkTooltip content={tooltip_html} className="tooltip" element_type="datatooltip" /> }
          { (percentage || number_students_tested) && display_percentages && renderStudentPercentage() }
        </div>
        <div className="col-sm-1" />
        <div className="col-xs-9 col-sm-4">
          {children}
        </div>
        <div className="compare-link">
          {(link && renderCompareLink()) || drawerTrigger}
        </div>
      </div>
    </div>
  );
};

BasicDataModuleRow.propTypes = {
  breakdown: PropTypes.string.isRequired,
  label: PropTypes.string,
  percentage: PropTypes.string,
  display_percentages: PropTypes.bool,
  number_students_tested: PropTypes.number,
  drawerTrigger: PropTypes.element,
  tooltip_html: PropTypes.string,
  children: PropTypes.element.isRequired,
  link: PropTypes.string
}

BasicDataModuleRow.defaultProps = {
  display_percentages: false
}

export default BasicDataModuleRow;
