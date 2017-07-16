import React, { PropTypes } from 'react';

export default class Rating extends React.Component {

  static propTypes = {
    breakdown: React.PropTypes.string.isRequired,
    score: React.PropTypes.number.isRequired,
    label: React.PropTypes.string.isRequired,
    percentage: React.PropTypes.string,
    display_percentages: React.PropTypes.bool,
    number_students_tested: React.PropTypes.number,
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
    }[Math.ceil(value)]
  }

  renderKey(){
    return this.props.breakdown + Math.random();
  }

  render() {
    return (
        <div className="bar-graph-container tar">
          <div className="advanced-courses">
            <span className={"gs-rating-inline circle-rating--xtra-small circle-rating--" + this.props.score}>{this.props.score}<span class="denominator">/10</span></span>
          </div>
        </div>
    )
  }
}

