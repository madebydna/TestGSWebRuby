import React from 'react';
import PropTypes from 'prop-types';

export default class CaptureOutsideClick extends React.Component {
  static propTypes = {
    callback: PropTypes.func.isRequired,
    children: PropTypes.element.isRequired
  };

  constructor(props) {
    super(props);
    this.ref = React.createRef();
  }

  componentDidMount() {
    document.addEventListener('mousedown', this.handleClick(), false);
  }

  componentWillUnmount() {
    document.removeEventListener('mousedown', this.handleClick(), false);
  }

  handleClick() {
    return e => {
      if (this.ref === undefined || this.ref.current.contains(e.target)) {
        return;
      }
      this.props.callback();
    };
  }

  render() {
    return React.cloneElement(this.props.children, {
      ref: this.ref
    });
  }
}
