import React, { PropTypes } from 'react';

export default class PlainNumber extends React.Component {
  static propTypes = {
    values: React.PropTypes.arrayOf(React.PropTypes.shape({
      breakdown: React.PropTypes.string.isRequired,
      score: React.PropTypes.number.isRequired,
      percentage: React.PropTypes.string,
      display_percentages: React.PropTypes.bool,
      number_students_tested: React.PropTypes.string,
      state_average: React.PropTypes.number
    })).isRequired
  };

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
          return <span className="subject-subtext"><br />({test_data['percentage']}{this.translateString('of students')} )</span>
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
                    {value['score']}
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

