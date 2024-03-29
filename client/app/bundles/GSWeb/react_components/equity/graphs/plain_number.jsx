import React from 'react';
import PropTypes from 'prop-types';

export default class PlainNumber extends React.Component {
  static propTypes = {
    values: PropTypes.arrayOf(PropTypes.shape({
      breakdown: PropTypes.string.isRequired,
      score: PropTypes.number.isRequired,
      percentage: PropTypes.string,
      display_percentages: PropTypes.bool,
      number_students_tested: PropTypes.string,
      state_average: PropTypes.number,
      precision: PropTypes.number
    })).isRequired
   };

  static defaultProps = {
    precision: 1
  }

  constructor(props) {
    super(props);
  }

  renderStudentPercentage(test_data){
    if(test_data['display_percentages']){
      if(test_data['percentage'] == '200'){
        if(test_data['number_students_tested'] > 0) {
          return <span className="subject-subtext"><br />({test_data['number_students_tested']} {this.translateString('students')})</span>
        }
      }
      else {
        if (test_data['percentage']) {
          return <span className="subject-subtext"><br />({test_data['percentage']}{this.translateString('percentage of students')} )</span>
        }
      }
    }
  }

  translateString(str){
    return gon.translations[str];
  }

  renderStateAverage(state_average) {
    if(state_average !== null && state_average !== undefined && parseFloat(state_average) >= 0) {
      return (<div className="state-average">
        {this.translateString('State avg')} {state_average}
      </div>)
    }
  }

  renderRow(value){
    if (value !== undefined) {
      return (
          <div key={value['breakdown']} className="rating-container__score-item equity-test-scores">
            <div className="rating-score-item">
              <div className="row">
                <div className="col-xs-6 subject">
                  {value['breakdown']}
                  {this.renderStudentPercentage(value)}
                </div>
                <div className="col-xs-6 horizontal">
                  <div className="score">
                    {value['score'].toFixed(this.props.precision)}
                  </div>
                  {this.renderStateAverage(value['state_average'])}
                </div>
              </div>
            </div>
          </div>
      );
    }
  }

  render() {
    let rows = [];
    this.props.values.forEach((value) => rows.push(this.renderRow(value)));
    return <div>
      {rows}
    </div>
  }
}

