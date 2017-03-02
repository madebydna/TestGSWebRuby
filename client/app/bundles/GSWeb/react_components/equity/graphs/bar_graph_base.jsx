import React, { PropTypes } from 'react';
import BarGraph from '../../bar_graph';

export default class BarGraphBase extends React.Component {

  static propTypes = {
    test_scores: React.PropTypes.arrayOf(React.PropTypes.shape({
      breakdown: React.PropTypes.string.isRequired
    })).isRequired
  }

  constructor(props) {
    super(props);
    // this.series = this.series.bind(this);
    // this.seriesData = this.seriesData.bind(this);
    // this.categories = this.categories.bind(this);
    this.mapColor = this.mapColor.bind(this);
  }

  // testScores() {
  //   return (
  //       _.sortBy(
  //           this.props.test_scores.filter(obj => obj.school_value !== undefined),
  //           obj => {
  //             if (obj.breakdown == 'All students') {
  //               return -150;
  //             } else if (obj.percentOfStudentBody) {
  //               return -obj.percentOfStudentBody;
  //             } else {
  //               return 100; // default to bottom
  //             }
  //           }
  //       )
  //   );
  // }

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
      let style_arrow_down = {left: state_average + "%", top:'11px'}
      return <div className="arrow-up"><span style={style_arrow_down}></span></div>
    }
  }

  renderStudentPercentage(test_data){
    if(test_data['breakdown'] == 'Economically disadvantaged' || test_data['breakdown'] == 'Not economically disadvantaged'){
      return
    }
    if(test_data['percentage'] == '200'){
      return <span className="subject-subtext"><br />({test_data['number_students_tested']} students)</span>
    }
    return <span className="subject-subtext"><br />({test_data['percentage']}% of students)</span>
  }

  renderBarGraph(test_data){
    if(test_data !== undefined) {

      let style_score_width = {width: test_data['score']+"%", backgroundColor: this.mapColor(test_data['score'])}
      let style_grey_width = {width: 100-test_data['score']+"%" }

      return (
        <div className="rating-container__score-item equity_test_scores">
          <div className="rating-score-item">
            <div className="row">
              <div className="col-xs-6 subject">
                {test_data['breakdown']}
                {this.renderStudentPercentage(test_data)}
              </div>
              <div className="col-xs-6">
                <div className="score">
                  {test_data['score']}%
                </div>
                <div className="item-bar">
                  <div className="row">
                    <div className="col-xs-12">
                      <div className="single-bar-viz ">
                        <div className="color-row rating_8" style={style_score_width}></div>
                        <div className="grey-row" style={style_grey_width}></div>
                        {this.renderStateAverageArrow(test_data['state_average'])}
                      </div>

                    </div>
                  </div>
                </div>
                <div className="state-average">
                  State avg: {test_data['state_average']}%
                </div>
              </div>
            </div>

          </div>
        </div>
      );
    }
  }

  render() {
    let graphs = []
    let self = this;
    this.props.test_scores.forEach(function(test_data) {
      graphs.push(self.renderBarGraph(test_data))
    })
    return <div>
      {graphs}
    </div>
  }
}

