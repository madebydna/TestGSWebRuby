import React, { PropTypes } from 'react';

export default class SpinnyWheel extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    let spinnyWheelStyle = {
     backgroundPosition: this.props.backgroundPosition
    }
    return (
      <div className="spinny-wheel-container">
        <div style={spinnyWheelStyle} className="spinny-wheel"></div>
        {this.props.content}
      </div>
    );
  }
}

SpinnyWheel.defaultProps = {
  backgroundPosition: 'center'
}

SpinnyWheel.propTypes = {
  backgroundPosition: React.PropTypes.string
}
