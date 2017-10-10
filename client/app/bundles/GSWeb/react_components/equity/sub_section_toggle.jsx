import React, { PropTypes } from 'react';
import SectionSubNavigation from './tabs/section_sub_navigation';
import EquityContentPane from './equity_content_pane';
import { handleThirdAnchor, addAnchorChangeCallback, removeAnchorChangeCallback } from '../../components/anchor_router';

export default class SubSectionToggle extends React.Component {

  static propTypes = {
    active: React.PropTypes.number,
    parent_anchor: React.PropTypes.string,
    panes: React.PropTypes.arrayOf(React.PropTypes.node)
  };

  static defaultProps = {
    active: 0
  }

  constructor(props) {
    super(props);
    this.state = {
      active: props.active
    };
  }

  componentWillReceiveProps(nextProps) {
    if(nextProps.active != this.props.active) {
      this.setState({active: nextProps.active})
    }
  }

  componentDidMount() {
    this.props.selectTabMatchingAnchor();
    addAnchorChangeCallback(this.props.selectTabMatchingAnchor);
  }

  componentWillUnmount() {
    removeAnchorChangeCallback(this.props.selectTabMatchingAnchor);
  }

  render() {
    let pane = this.props.panes[this.state.active];
    return pane;
  }
}
