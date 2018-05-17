import React from 'react';
import PropTypes from 'prop-types';
import { size } from 'util/viewport';

// Given an element, allow it to be opened/closed
//
// The children passed into this component must be a function that
// accepts isOpen, and chosen function references(toggle, open, close).
// It will use those as desired
export default class SizeMappable extends React.Component {
  static propTypes = {
    renderXs: PropTypes.func,
    renderSm: PropTypes.func,
    renderMd: PropTypes.func,
    renderLg: PropTypes.func
  }

  constructor(props) {
    super(props);

    let xs = props.renderXs;
    let sm = props.renderSm || xs;
    let md = props.renderMd || sm;
    let lg = props.renderLg || lg;

    this.state = {
      xs: xs,
      sm: sm,
      md: md,
      lg: lg 
    }
  }

  render() {
    let renderFunc = this.state[size()];
    return renderFunc(size());
  }
}
