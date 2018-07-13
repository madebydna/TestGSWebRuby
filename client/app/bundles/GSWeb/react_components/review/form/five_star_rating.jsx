import React from 'react';
import PropTypes from 'prop-types';

export default class FiveStarRating extends React.Component {
  static propTypes = {
    value: PropTypes.number,
    questionId: PropTypes.number.isRequired,
    onClick: PropTypes.func.isRequired
  };

  constructor(props) {
    super(props);
    this.handleStarResponseClick = this.handleStarResponseClick.bind(this);
  }

  handleStarResponseClick(value) {
    return () => this.props.onClick(value, this.props.questionId);
  }

  fiveStars(numberFilled) {
    const filled = [];
    for (var i = 0; i < numberFilled; i++) {
      filled.push(
        <span
          className="icon-star filled-star"
          onClick={this.handleStarResponseClick(i + 1)}
          key={i}
        />
      );
    }
    const empty = [];
    for (i = numberFilled; i < 5; i++) {
      empty.push(
        <span
          className="icon-star empty-star"
          onClick={this.handleStarResponseClick(i + 1)}
          key={i}
        />
      );
    }
    return (
      <div className="five-star-rating__stars--med">
        <span className="five-stars">
          {filled}
          {empty}
        </span>
      </div>
    );
  }

  render() {
    return (
      <div className="five-star-rating">{this.fiveStars(this.props.value)}</div>
    );
  }
}
