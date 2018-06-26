import React from 'react';
import PropTypes from 'prop-types';
import { throttle, debounce } from 'lodash';
import {
  amountElementTopAboveViewport,
  amountElementBottomBelowViewport
} from 'util/viewport';

class SchoolListOverlay extends React.Component {
  static propTypes = {
    visible: PropTypes.bool,
    numItems: PropTypes.number
  };

  static defaultProps = {
    visible: true,
    numItems: 0
  };

  constructor(props) {
    super(props);
    this.domElement = React.createRef();
    this.state = {
      top: 0,
      bottom: 300
    };
    this.updateHeight = this.updateHeight.bind(this);
  }

  componentDidMount() {
    this.updateHeight();
    $(() => {
      $(window).on('scroll', throttle(this.updateHeight, 40));
      $(window).on('resize', debounce(this.updateHeight, 80));
    });
  }

  componentDidUpdate(prevProps) {
    if (
      prevProps.numItems !== this.props.numItems ||
      prevProps.visible !== this.props.visible
    ) {
      // if the list grows/shrinks, update height
      this.updateHeight();
    }
  }

  updateHeight() {
    const parent = this.domElement.current.parentNode;
    this.setState({
      top: Math.max(0, amountElementTopAboveViewport(parent)),
      bottom: Math.max(0, amountElementBottomBelowViewport(parent))
    });
  }

  render() {
    return (
      <div
        className="school-list-overlay"
        ref={this.domElement}
        style={{
          top: this.state.top,
          bottom: this.state.bottom,
          display: this.props.visible ? 'block' : 'none'
        }}
      >
        <div className="loader" />
      </div>
    );
  }
}

export default SchoolListOverlay;
