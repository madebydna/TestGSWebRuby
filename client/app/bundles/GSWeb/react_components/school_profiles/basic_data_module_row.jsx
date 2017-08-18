import React from 'react';
import QuestionMarkTooltip from './question_mark_tooltip';
import { t } from '../../util/i18n';

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
}) => {

  const renderStudentPercentage = function(){
    if(display_percentages){
      if(percentage == '200' || breakdown == 'All students' || breakdown == 'Todos los estudiantes'){
        if(number_students_tested > 0) {
          return <span className="subject-subtext"> <br className="br_except_for_mobile" />({number_students_tested} {t('students')})</span>
        }
      }
      else {
        if (percentage > 0) {
          return <span className="subject-subtext"> <br className="br_except_for_mobile" />({percentage}{t('of students')} )</span>
        }
      }
    }
  }

  return (
    <div className="row bar-graph-display">
      <div className="test-score-container clearfix">
        <div className="col-xs-12 col-sm-5 subject">
          {breakdown}&nbsp;{ tooltip_html && <QuestionMarkTooltip content={tooltip_html} /> }
          { (percentage || number_students_tested) && display_percentages && renderStudentPercentage() }
        </div>
        <div className="col-sm-1"></div>
        <div className="col-xs-9 col-sm-4">
          {children}
        </div>
        <div className="col-xs-3 col-sm-2">
          {drawerTrigger}
        </div>
      </div>
    </div>
  );
};

BasicDataModuleRow.PropTypes = {
  breakdown: React.PropTypes.string.isRequired,
  label: React.PropTypes.string,
  percentage: React.PropTypes.string,
  display_percentages: React.PropTypes.bool,
  number_students_tested: React.PropTypes.number,
  drawerTrigger: React.PropTypes.element,
  tooltip_html: React.PropTypes.string,
  children: React.PropTypes.element.isRequired
}

BasicDataModuleRow.DefaultProps = {
  display_percentages: false
}

export default BasicDataModuleRow;
