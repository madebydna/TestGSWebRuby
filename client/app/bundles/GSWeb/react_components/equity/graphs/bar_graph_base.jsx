import React, { PropTypes } from 'react';

export default class BarGraphBase extends React.Component {

  static propTypes = {
    test_scores: React.PropTypes.arrayOf(React.PropTypes.shape({
      breakdown: React.PropTypes.string.isRequired
    })).isRequired
  }

  constructor(props) {
    super(props);
    this.mapColor = this.mapColor.bind(this);
  }

  // helper method to map a score to a color for bars
  mapColor(value) {
    return {
      1: '#F26B16',
      2: '#E78818',
      3: '#DCA21A',
      4: '#D2B81B',
      5: '#BDC01E',
      6: '#A3BE1F',
      7: '#86B320',
      8: '#6BA822',
      9: '#559F24',
      10: '#439326'
    }[Math.ceil(value/10)]
  }


  renderStateAverageArrow(state_average){
    if(state_average > 0) {
      let style_arrow_up = {left: state_average + "%", top:'11px'}
      return <div className="arrow-up"><span style={style_arrow_up}></span></div>
    }
  }

  renderStudentPercentage(test_data){
    if(test_data['display_percentages']){
      if(test_data['percentage'] == '200' || test_data['breakdown'] == 'All students' || test_data['breakdown'] == 'Todos los estudiantes'){
        if(test_data['number_students_tested'] > 0) {
          return <span className="subject-subtext"><br />({test_data['number_students_tested']} {GS.I18n.t('students')})</span>
        }
      }
      else {
        if (test_data['percentage'] > 0) {
          return <span className="subject-subtext"><br />({test_data['percentage']}{GS.I18n.t('of students')} )</span>
        }
      }
    }
  }

  renderStateAverage(state_average) {
      if(state_average != null && state_average != undefined && parseInt(state_average) > 0 && parseInt(state_average) <= 100) {
        return (<div className="state-average">
          {GS.I18n.t('State avg')} {state_average}%
        </div>)
      }
  }

  renderKey(test_data){
    return test_data['breakdown']+Math.random();
  }

  renderBarGraph(test_data){
    if(test_data !== undefined) {
      let numerical_value = test_data['score'];
      if (numerical_value == '<1') {
        numerical_value = '0';
      }
      let style_score_width = {width: numerical_value+"%", backgroundColor: this.mapColor(test_data['score'])};
      let style_grey_width = {width: 100-numerical_value+"%" };
      return (
        <div key={this.renderKey(test_data)} className="rating-container__score-item equity-test-scores">
          <div className="rating-score-item">
            <div className="row">
              <div className="col-xs-6 subject">
                {test_data['breakdown']}
                {this.renderStudentPercentage(test_data)}
              </div>
              <div className="col-xs-6">
                <div className="score">
                  {test_data['label']}%
                </div>
                <div className="item-bar">
                  <div className="row">
                    <div className="col-xs-12">
                      <div className="single-bar-viz ">
                        <div className="color-row" style={style_score_width}></div>
                        <div className="grey-row" style={style_grey_width}></div>
                        {this.renderStateAverageArrow(test_data['state_average'])}
                      </div>

                    </div>
                  </div>
                </div>
                {this.renderStateAverage(test_data['state_average'])}
              </div>
            </div>
          </div>
        </div>
      );
    }
  }

  render() {
    let graphs = []
    this.props.test_scores.forEach((test_data) => graphs.push(this.renderBarGraph(test_data)))
    return <div>
      {graphs}
    </div>
  }
}

