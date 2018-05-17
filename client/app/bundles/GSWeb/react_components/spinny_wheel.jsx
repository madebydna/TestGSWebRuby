import React from 'react';
import PropTypes from 'prop-types';

export default class SpinnyWheel extends React.Component {

  static defaultProps = {
    backgroundPosition: 'center',
    spin: true
  }

  static propTypes = {
    backgroundPosition: PropTypes.string,
    spin: PropTypes.bool
  }

  constructor(props) {
    super(props);
  }

  render() {
    let spinnyWheelStyle = {
     backgroundPosition: this.props.backgroundPosition
    }
    if(this.props.spin) {
      return (
        <div className="spinny-wheel-container">
          { this.props.active !== false && <div style={spinnyWheelStyle} className="spinny-wheel"></div> }
          {this.props.content}
          {this.props.children}
        </div>
      );
    } else {
      return this.props.content || this.props.children;
    }
  }
}
