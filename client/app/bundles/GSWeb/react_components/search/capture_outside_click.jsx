import React from 'react';
import PropTypes from 'prop-types';

// The purpose of this is to keep track of a dom reference on mount,
// and fire a callback if a click event occurs anywhere outside of the
// childrens' dom tree. Used for things like clicking a dropdown
// menu when user clicks outside of it.
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
