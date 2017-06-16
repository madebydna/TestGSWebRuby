import React, { PropTypes } from 'react';

export default class BarGraphBase extends React.Component {

  static propTypes = {
    breakdown: React.PropTypes.string.isRequired,
    score: React.PropTypes.number.isRequired,
    label: React.PropTypes.string.isRequired,
    percentage: React.PropTypes.string,
    display_percentages: React.PropTypes.bool,
    number_students_tested: React.PropTypes.string,
    state_average: React.PropTypes.number,
    state_average_label: React.PropTypes.string,
    invertedRatings:  React.PropTypes.bool
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

  renderStateAverage(state_average) {
      if(state_average != null && state_average != undefined && parseInt(state_average) > 0 && parseInt(state_average) <= 100) {
        return (<div className="state-average">
          {GS.I18n.t('State avg')} {state_average}%
        </div>)
      }
  }

  renderKey(){
    return this.props.breakdown + Math.random();
  }

  renderStateAverage(state_average) {
    if(state_average != null && state_average != undefined && parseInt(state_average) > 0 && parseInt(state_average) <= 100) {
      return (<div className="state-average">
        {GS.I18n.t('State avg')} {state_average}%
      </div>)
    }
  }

  renderStateAverageArrow(state_average){
    if(state_average > 0) {
      let style_arrow_up = {left: state_average + "%", top:'11px'}
      return <div className="arrow-up"><span style={style_arrow_up}></span></div>
    }
  }

  render() {
    let numerical_value = this.props.score;
    if (numerical_value == '<1') {
      numerical_value = '0';
    }
    let style_score_width = {width: numerical_value+"%", backgroundColor: this.mapColor(this.props.score)};
    let style_grey_width = {width: 100-numerical_value+"%" };

    return (
      <div className="bar-graph-container">
        <div className="score">{this.props.label}%</div>
        <div className="viz">
          <div className="item-bar">
            <div className="single-bar-viz">
              <div className="color-row" style={style_score_width}></div>
              <div className="grey-row" style={style_grey_width}></div>
              {this.renderStateAverageArrow(this.props.state_average)}
            </div>
          </div>
          {this.renderStateAverage(this.props.state_average)}
        </div>
      </div>
    )
  }
}

