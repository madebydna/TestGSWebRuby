import React, { PropTypes } from 'react';
import { formatAnchorString, hashSeparatorAnchor } from '../../../components/anchor_router';

export default class SectionSubNavigation extends React.Component {
  render(){
    var active = this.props.active;
    var items = this.props.items.map(function(hash, index) {
      let anchor = this.props.top_anchor + hashSeparatorAnchor() + this.props.parent_anchor + hashSeparatorAnchor() + formatAnchorString(hash.anchor);
      return <a href="javascript:void(0)"
                data-anchor={anchor}
                key={index}
                className={'sub-nav-item js-gaClick js-updateLocationHash' + (active === index ? ' sub-tab-selected' : '')}
                onClick={this.onClick.bind(this, index)}
                data-ga-click-category='Profile'
                data-ga-click-action='Equity Ethnicity Button'
                data-ga-click-label={hash.subject}>
        {hash.subject}
      </a>;
    }.bind(this));
    return <div className="sub-nav-group">{items}</div>;
  }

  onClick(index) {
    this.props.onTabClick(index);
  }
};
