import React from 'react';
import PropTypes from 'prop-types';

const doesElementHaveClass = (element, className) =>
  ` ${element.className} `.replace(/[\n\t]/g, ' ').indexOf(` ${className} `) >
  -1;

// The purpose of this is to keep track of a dom reference on mount,
// and fire a callback if a click event occurs anywhere outside of the
// childrens' dom tree. Used for things like clicking a dropdown
// menu when user clicks outside of it.

// NOTE: The first child of this component must be an html element for the ref to work properly
export default class CaptureOutsideClick extends React.Component {
  static propTypes = {
    callback: PropTypes.func.isRequired,
    children: PropTypes.element.isRequired,
    ignoreClassNames: PropTypes.arrayOf(PropTypes.string) // ignore event targets that contain any of these class names
  };

  static defaultProps = {
    ignoreClassNames: []
  };

  constructor(props) {
    super(props);
    this.ref = React.createRef();
  }

  componentDidMount() {
    document.addEventListener('mousedown', this.handleClick(), false);
    document.addEventListener('touchend', this.handleClick(), false);
  }

  componentWillUnmount() {
    document.removeEventListener('mousedown', this.handleClick(), false);
    document.removeEventListener('touchend', this.handleClick(), false);
  }

  handleClick() {
    return e => {
      if (
        this.ref === undefined ||
        this.ref.current === null ||
        this.ref.current.contains(e.target) ||
        this.props.ignoreClassNames.find(filter =>
          doesElementHaveClass(e.target, filter)
        )
      ) {
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
