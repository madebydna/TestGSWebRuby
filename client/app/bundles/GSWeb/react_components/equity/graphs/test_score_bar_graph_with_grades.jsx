import React from 'react';
import PropTypes from 'prop-types';
import BarGraphBase from './bar_graph_base';
import BasicDataModuleRow from '../../school_profiles/basic_data_module_row';
import BasicDataModuleDrawerRow from '../../school_profiles/basic_data_module_drawer_row';
import { t } from '../../../util/i18n';

export default class TestScoreBarGraphWithGrades extends React.Component {

  static propTypes = {
    breakdown: PropTypes.string.isRequired,
    score: PropTypes.number.isRequired,
    label: PropTypes.string.isRequired,
    percentage: PropTypes.string,
    display_percentages: PropTypes.bool,
    number_students_tested: PropTypes.number,
    state_average: PropTypes.number,
    state_average_label: PropTypes.string,
    grades: PropTypes.array,
    invertedRatings:  PropTypes.bool
  }

  constructor(props) {
    super(props);
  }

  renderDetailsLink(grades) {
    if (grades != null && grades != undefined && grades.constructor === Array && grades.length > 0) {
      return <div className="details js-test-score-details">{t('details')}  <span className="icon-caret-down rotate-text-270 move-icon"></span></div>
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
            let label = <span> {t('grade')} {test_data_for_grade.grade} </span>
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

