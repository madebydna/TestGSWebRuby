import React from 'react';
import PropTypes from 'prop-types';
import { t } from '../../util/i18n';
import CircleCheck from '../icons/circle_check';
import CircleDash from '../icons/circle_dash';
import CircleX from '../icons/circle_x';

export default class Circle extends React.Component {
  static propTypes = {
    value: PropTypes.string.isRequired
    // breakdown: PropTypes.string.isRequired,
    // score: PropTypes.number.isRequired,
    // label: PropTypes.string.isRequired,
    // percentage: PropTypes.string,
    // display_percentages: PropTypes.bool,
    // number_students_tested: PropTypes.string,
    // state_average: PropTypes.number,
    // state_average_label: PropTypes.string,
    // invertedRatings:  PropTypes.bool,
    // use_gray: PropTypes.bool
  };

  constructor(props) {
    super(props);
    this.renderCircle = this.renderCircle.bind(this);
    this.renderKey = this.renderKey.bind(this);
  }

  renderCircle() {
    if (this.props.value === 'All') {
      return <CircleCheck key={this.renderKey()} />;
    } else if (this.props.value === 'Partial') {
      return (
        <div>
          <CircleDash key={this.renderKey()} />
          <div>Some grades</div>
        </div>
      );
    } else {
      return <CircleX key={this.renderKey()} />;
    }
  }



  renderKey() {
    return this.props.breakdown + Math.random();
  }

  render() {
    return (
      <div className="circle-container">
        {this.renderCircle()}
      </div>
    );
  }
}
