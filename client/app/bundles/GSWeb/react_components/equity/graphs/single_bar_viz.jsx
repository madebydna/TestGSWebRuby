import React from 'react';
import PropTypes from 'prop-types';

export default class SingleBarViz extends React.Component {

  static propTypes = {
    score: PropTypes.number.isRequired,
    state_average: PropTypes.number,
    lower_range: PropTypes.number,
    upper_range: PropTypes.number
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

  validStateAverageValue() {
    let state_average = this.props.state_average;
    let lower_range = this.props.lower_range || 0
    let upper_range = this.props.upper_range || 100;
    return (
      state_average != null && 
      state_average != undefined && 
      parseInt(state_average) >= lower_range &&
      parseInt(state_average) <= upper_range
    );
  }

  coloredBandWidth(prop) {
    if (this.props.lower_range && this.props.upper_range) {
      let spread = this.props.upper_range - this.props.lower_range;
      return Math.round(((prop - this.props.lower_range)/spread)*100);
    } else {
      return prop;
    }
  }

  renderStateAverageArrow(){
    if(this.validStateAverageValue()) {
      let style_arrow_up = {
        left: this.coloredBandWidth(this.props.state_average) + "%",
        top: '11px'
      }
      return <div className="arrow-up">
        <span style={style_arrow_up}></span>
      </div>
    }
  }

  render() {
    let numerical_value = this.coloredBandWidth(this.props.score);
    let style_score_width = {
      width: numerical_value + "%",
      backgroundColor: this.mapColor(numerical_value)
    };
    let style_grey_width = { width: 100 - numerical_value + "%" };

    return (
      <div className="single-bar-viz">
        <div className="color-row" style={style_score_width}></div>
        <div className="grey-row" style={style_grey_width}></div>
        {this.props.state_average && this.renderStateAverageArrow()}
      </div>
    )
  }
}
