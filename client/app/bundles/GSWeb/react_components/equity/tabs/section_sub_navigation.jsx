import React from 'react';
import PropTypes from 'prop-types'; // importing from react is deprecated
import { formatAnchorString, hashSeparatorAnchor } from '../../../components/anchor_router';

export default class SectionSubNavigation extends React.Component {
  static propTypes = {
    active: PropTypes.number,
    items: PropTypes.arrayOf(PropTypes.shape({
      anchor: PropTypes.string,
      title: PropTypes.string,
      flagged: PropTypes.bool
    })),
    onTabClick: PropTypes.func,
    parent_anchor: PropTypes.string,
    top_anchor: PropTypes.string
  };

  render(){
    var active = this.props.active;
    var items = this.props.items.map(function(item, index) {
      let flagged = item.flagged || false;
      let anchor = this.props.top_anchor + hashSeparatorAnchor() + this.props.parent_anchor + hashSeparatorAnchor() + formatAnchorString(item.anchor);
      return <a href="javascript:void(0)"
                data-anchor={anchor}
                key={index}
                className={'sub-nav-item js-gaClick js-updateLocationHash' + (active === index ? ' sub-tab-selected' : '')}
                onClick={this.onClick.bind(this, index)}
                data-ga-click-category='Profile'
                data-ga-click-action='Equity Ethnicity Button'
                data-ga-click-label={item.title}>
        {item.title}
        {this.addFlag(flagged)}
      </a>;
    }.bind(this));
    return <div className="sub-nav-group">{items}</div>;
  }

  addFlag(flag) {
    if (flag === true) {
      return <span className="icon-flag red"/>
    }
  }

  onClick(index) {
    this.props.onTabClick(index);
  }
};
