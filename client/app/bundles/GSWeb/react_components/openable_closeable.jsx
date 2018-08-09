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
  };

  static defaultProps = {
    openByDefault: false,
    onChange: isOpen => {}
  };

  constructor(props) {
    super(props);
    this.toggle = this.toggle.bind(this);
    this.open = this.open.bind(this);
    this.openForDuration = this.openForDuration.bind(this);
    this.close = this.close.bind(this);
    this.state = {
      isOpen: props.openByDefault,
      whenOutOfTimeIntervalId: null,
      interval: null
    };
  }

  open() {
    this.clearIntervals();
    this.setState({ isOpen: true }, () => this.props.onChange(this.isOpen));
  }

  whenOutOfTime = onOutOfTime => () => {
    const remainingTime = this.state.remainingTime - this.state.interval;
    if (remainingTime <= 0) {
      onOutOfTime();
    }
    this.setState({
      remainingTime
    });
  };

  openForDuration(duration, interval = null) {
    this.clearIntervals();
    this.setState({ isOpen: true }, () => {
      this.props.onChange(this.isOpen);
      this.setState({
        remainingTime: duration,
        interval: interval || duration,
        whenOutOfTimeIntervalId: window.setInterval(
          this.whenOutOfTime(() => {
            this.close();
            this.clearIntervals();
          }),
          interval
        )
      });
    });
  }

  close() {
    this.clearIntervals();
    this.setState({ isOpen: false }, () => this.props.onChange(this.isOpen));
  }

  toggle() {
    this.setState({ isOpen: !this.state.isOpen }, () =>
      this.props.onChange(this.isOpen)
    );
  }

  clearIntervals() {
    if (this.state.whenOutOfTimeIntervalId) {
      window.clearInterval(this.state.whenOutOfTimeIntervalId);
      this.setState({
        whenOutOfTimeIntervalId: null
      });
    }
  }

  render() {
    return this.props.children(this.state.isOpen, {
      toggle: this.toggle,
      open: this.open,
      close: this.close,
      openForDuration: this.openForDuration,
      remainingTime: this.state.remainingTime > 0 ? this.state.remainingTime : 0
    });
  }
}
