import React from 'react';
import PropTypes from 'prop-types'; // importing from react is deprecated
import { formatAnchorString, hashSeparatorAnchor } from '../../../components/anchor_router';
import { map } from 'lodash';

export default class SectionNavigation extends React.Component {
  static propTypes = {
    active: PropTypes.number
  };

  highlight(item) {
    return React.cloneElement(
      item,
      {
        className: item.props.className + ' tab-selected',
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
      return <div key={index} className="tab-container">
        {item}{this.addDivider(index)}
      </div>
    }.bind(this));
    if(items != undefined ) return <div className="clearfix">{items}</div>;
  };

  addDivider(index) {
    var last_item = this.props.children.length - 1;
    if(index != last_item){
      return <span className="divider" />
    }
  }
};
