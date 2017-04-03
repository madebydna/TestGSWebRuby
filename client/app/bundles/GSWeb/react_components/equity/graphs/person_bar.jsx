import React, { PropTypes } from 'react';

export default class PersonBar extends React.Component {
  static propTypes = {
    values: React.PropTypes.arrayOf(React.PropTypes.shape({
      breakdown: React.PropTypes.string.isRequired,
      score: React.PropTypes.string.isRequired,
      percentage: React.PropTypes.string,
      display_percentages: React.PropTypes.bool,
      number_students_tested: React.PropTypes.string,
      state_average: React.PropTypes.string
    })).isRequired,
    invertedRatings:  React.PropTypes.bool
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
    return GS.I18n.t(str);
  }

  renderStateAverage(state_average) {
    if(state_average != null && state_average != undefined && parseInt(state_average) > 0 && parseInt(state_average) <= 100) {
      return (<div className="state-average">
        {GS.I18n.t('State avg')} {state_average}%
      </div>)
    }
  }

  renderStateAverageArrow(state_average){
    if(state_average != null && state_average != undefined && parseInt(state_average) > 0 && parseInt(state_average) <= 100) {
      let style_arrow_up = {left: state_average + "%", top: '-1px'};
      return <div className="arrow-up"><span style={style_arrow_up}/></div>
    }
  }

  renderRow(value){
    if (value !== undefined && value['score'] !== undefined) {
      let ten = [1,2,3,4,5,6,7,8,9,10];
      let numerical_value = value['score'];
      if (numerical_value == '<1') {
        numerical_value = '0';
      }
      let style_score_width = {width: numerical_value + "%"};
      let score_rating = Math.trunc(numerical_value / 10.0) + 1;
      if (score_rating > 10) {
        score_rating = 10;
      } else if (score_rating < 1) {
        score_rating = 1;
      }
      if(this.props.invertedRatings) {
        score_rating = 11 - score_rating;
      }

      let class_score_rating = 'foreground rating_color_' + score_rating;
      return (
          <div key={value['breakdown']} className="rating-container__score-item equity-test-scores">
            <div className="rating-score-item">
              <div className="row">
                <div className="col-xs-6 subject">
                  {value['breakdown']}
                  {this.renderStudentPercentage(value)}
                </div>
                <div className="col-xs-6">
                  <div className="score">
                    {value['score']}%
                  </div>
                  <div className="person-bar-viz">
                    <div className="person-progress">
                      <div className="background">
                        {ten.map((i) => (
                            <span key={'back' + i} className="icon-person"/>
                        ))}
                      </div>
                      <div className={class_score_rating} style={style_score_width}>
                        {ten.map((i) => (
                            <span key={'fore' + i} className="icon-person"/>
                        ))}
                      </div>
                    </div>
                    {this.renderStateAverageArrow(value['state_average'])}
                    {this.renderStateAverage(value['state_average'])}
                  </div>
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