import React from 'react';
import PropTypes from 'prop-types'; // importing from react is deprecated
import { formatAnchorString, hashSeparatorAnchor } from '../../../components/anchor_router';

export default class SectionSubNavigation extends React.Component {
  static propTypes = {
    active: PropTypes.number
  };

  static defaultProps = {
    active: 0
  }

  highlight(item) {
    return React.cloneElement(
      item,
      {
        className: item.props.className + ' sub-tab-selected',
        onClick: this.props.onTabClick
      }
    )
  }

  render() {
    if(!this.props.children) return null;
    var active = this.props.active;
    var items = this.props.children.map(function(item, index) {
      if(active == index) {
        item = this.highlight(item);
      }
      return item;
    }.bind(this));

    return <div className="sub-section-navigation">
      { items && <div className="sub-nav-group">{items}</div> }
    </div>
  };
};
