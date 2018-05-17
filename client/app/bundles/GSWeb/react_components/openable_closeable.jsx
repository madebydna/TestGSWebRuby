import React from 'react';
import PropTypes from 'prop-types';

// Given an element, allow it to be opened/closed
//
// The children passed into this component must be a function that
// accepts isOpen, and chosen function references(toggle, open, close).
// It will use those as desired
export default class OpenableCloseable extends React.Component {
  static propTypes = {
    openByDefault: PropTypes.bool,
    onChange: PropTypes.func
  }

  static defaultProps = {
    openByDefault: false,
    onChange: (isOpen) => {}
  }

  constructor(props) {
    super(props);
    this.toggle = this.toggle.bind(this);
    this.open = this.open.bind(this);
    this.close = this.close.bind(this);
    this.state = {
      isOpen: props.openByDefault
    }
  }

  open() {
    this.setState(
      { isOpen: true },
      () => this.props.onChange(this.isOpen)
    );
  }

  close() {
    this.setState(
      { isOpen: false },
      () => this.props.onChange(this.isOpen)
    );
  }

  toggle() {
    this.setState(
      { isOpen: !this.state.isOpen },
      () => this.props.onChange(this.isOpen)
    );
  }

  render() {
    return this.props.children(
      this.state.isOpen,
      {
        toggle: this.toggle,
        open: this.open,
        close: this.close
      }
    )
  }
}
