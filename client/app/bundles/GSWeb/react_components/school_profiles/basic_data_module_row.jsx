import React from 'react';

// TODOs:
// - rename subject css class
// - rename bar-graph-container css class

const t = function(string) {
  if (window.GS && GS.I18n && GS.I18n.t) {
    return GS.I18n.t(string) || string;
  } else {
    return string;
  }
}

const BasicDataModuleRow = ({
  breakdown,                // The short text description of the data type
  label,                    // The text version of the score/value
  percentage,               // The percentag of study body
  display_percentages,      // Whether or not to display % of student body
  number_students_tested,   // Absolute number of students the score applies to
  state_average_label,      // The text version of the state score/value
  children,                 // A visualization to put into this container
}) => {

  const renderStudentPercentage = function(){
    if(display_percentages){
      if(percentage == '200'){
        if(number_students_tested > 0) {
          return <span className="subject-subtext"><br />({number_students_tested} {t('students')})</span>
        }
      }
      else {
        if (percentage) {
          return <span className="subject-subtext"><br />({percentage}{t('of students')} )</span>
        }
      }
    }
  };

  return (
    <div className="row bar-graph-display">
      <div className="test-score-container clearfix">
        <div className="col-xs-12 col-sm-5 subject">
          {breakdown}
          { (percentage || number_students_tested) && display_percentages && renderStudentPercentage() }
        </div>
        <div className="col-sm-1"></div>
        <div className="col-xs-9 col-sm-4">
          {children}
        </div>
        <div className="col-xs-3 col-sm-2">
        </div>
      </div>
    </div>
  );
};

BasicDataModuleRow.PropTypes = {
}

export default BasicDataModuleRow;
