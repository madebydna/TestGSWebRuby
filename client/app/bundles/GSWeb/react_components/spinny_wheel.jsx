import React, { PropTypes } from 'react';

export default class SpinnyWheel extends React.Component {

  static defaultProps = {
    backgroundPosition: 'center'
  }

  static propTypes = {
    backgroundPosition: React.PropTypes.string
  }

  constructor(props) {
    super(props);
  }

  render() {
    let spinnyWheelStyle = {
     backgroundPosition: this.props.backgroundPosition
    }
    return (
      <div className="spinny-wheel-container">
        { this.props.active !== false && <div style={spinnyWheelStyle} className="spinny-wheel"></div> }
        {this.props.content}
        {this.props.children}
      </div>
    );
  }
}
