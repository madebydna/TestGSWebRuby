import React from 'react';
import PropTypes from 'prop-types'; // importing from react is deprecated
import { formatAnchorString, hashSeparatorAnchor } from '../../../components/anchor_router';
import { map } from 'lodash';

export default class SectionNavigation extends React.Component {
  static propTypes = {
    active: PropTypes.number,
    onTabClick: PropTypes.func
  };

  static defaultProps = {
    active: 0,
    onTabClick: () => {}
  }

  constructor(props) {
    super(props);
    this.onTabClick = this.onTabClick.bind(this);
    this.state = {
      active: props.active
    }
  }

  componentWillReceiveProps(nextProps) {
    if(nextProps.active != this.props.active) {
      this.setState({active: nextProps.active})
    }
  }

  onTabClick(index) {
    this.setState({active: index}, () => this.props.onTabClick(index))
  }

  tabs() {
    if(!this.props.children) return null;
    return this.props.children.map(function(tab, index) {
      let highlight = this.state.active == index;
      return [React.cloneElement(
        tab,
        {
          onClick: () => this.onTabClick(index),
          highlight: highlight
        }
      ), this.addDivider(index)]
    }.bind(this));
  }

  render() {
    let tabs = this.tabs();
    return <div className="clearfix">
      { tabs && <div className="tab-container">{tabs}</div> }
    </div>
  };

  addDivider(index) {
    var last_item = this.props.children.length - 1;
    if(index != last_item){
      return <span className="divider" />
    }
  }
};
