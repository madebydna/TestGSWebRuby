import React, { PropTypes } from 'react';
import SingleBarViz from './single_bar_viz';

export default class Rating extends React.Component {

  static propTypes = {
    score: React.PropTypes.number.isRequired,
  }

  constructor(props) {
    super(props);
  }

  render() {
    return (
      <div className="tar">
        <span className={"gs-rating-circle-inline circle-rating--xtra-small circle-rating--" + this.props.score}>{this.props.score}<span className="denominator">/10</span></span>
      </div>
    )
  }
}

