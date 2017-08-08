import React, { PropTypes } from 'react';
import BarGraphBase from './bar_graph_base';
import BasicDataModuleRow from '../../school_profiles/basic_data_module_row';
import BasicDataModuleDrawerRow from '../../school_profiles/basic_data_module_drawer_row';

export default class TestScoreBarGraphWithGrades extends React.Component {

  static propTypes = {
    breakdown: React.PropTypes.string.isRequired,
    score: React.PropTypes.number.isRequired,
    label: React.PropTypes.string.isRequired,
    percentage: React.PropTypes.string,
    display_percentages: React.PropTypes.bool,
    number_students_tested: React.PropTypes.number,
    state_average: React.PropTypes.number,
    state_average_label: React.PropTypes.string,
    grades: React.PropTypes.array,
    invertedRatings:  React.PropTypes.bool
  }

  constructor(props) {
    super(props);
  }

  renderDetailsLink(grades) {
    if (grades != null && grades != undefined && grades.constructor === Array && grades.length > 0) {
      return <div className="details js-test-score-details">{GS.I18n.t('details')}  <span className="icon-caret-down rotate-text-270 move-icon"></span></div>
    }
  }

  render(){
    return (
      <div>
        <BasicDataModuleRow {...this.props} drawerTrigger={this.renderDetailsLink(this.props.grades)} >
          <BarGraphBase {...this.props} />
        </BasicDataModuleRow>

        { this.props.grades && 
          this.props.grades.map((test_data_for_grade, index) => {
            let label = <span> {GS.I18n.t('grade')} {test_data_for_grade.grade} </span>
            return (
              <div className="grades" style={{display: 'none'}} key={index}>
                <BasicDataModuleDrawerRow {...test_data_for_grade} label={label}>
                  <BarGraphBase {...test_data_for_grade} />
                </BasicDataModuleDrawerRow>
              </div>
            );
          })
        }
      </div>
    );
  }
}

