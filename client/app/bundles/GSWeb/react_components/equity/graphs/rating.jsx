import React from 'react';
import PropTypes from 'prop-types';

export default class Rating extends React.Component {

  static propTypes = {
    score: PropTypes.number.isRequired,
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

