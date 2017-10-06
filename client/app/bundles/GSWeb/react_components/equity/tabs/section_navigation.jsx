import React from 'react';
import PropTypes from 'prop-types'; // importing from react is deprecated
import { formatAnchorString, hashSeparatorAnchor } from '../../../components/anchor_router';
import { map } from 'lodash';

export default class SectionNavigation extends React.Component {
  static propTypes = {
    active: PropTypes.number,
    google_tracking: PropTypes.string,
    items: PropTypes.arrayOf(PropTypes.shape({
      anchor: PropTypes.string,
      flagged: PropTypes.bool,
      title: PropTypes.string
    })),
    onTabClick: PropTypes.func,
    parent_anchor: PropTypes.string
  };

  render(){
    var active = this.props.active;
    var items = this.props.items.map(function(item, index) {
      let anchorLink = '';
      let addJSHashUpdate = '';
      if(item.anchor){
        addJSHashUpdate = ' js-updateLocationHash';
        anchorLink = this.props.parent_anchor + hashSeparatorAnchor() + formatAnchorString(item.anchor);
      }
      let flagged = item.flagged || false;
      return <div key={index} className="tab-container">
        <a href="javascript:void(0)"
                data-anchor={anchorLink}
                key={index}
                className={'tab-title js-gaClick' + addJSHashUpdate + (active === index ? ' tab-selected' : '')}
                onClick={this.onClick.bind(this, index)}
                data-ga-click-category='Profile'
                data-ga-click-action={this.googleTrackingAction()}
                data-ga-click-label={item.title}>
        {item.title}
        {this.addFlag(flagged)}
      </a>
        {this.addDivider(index)}</div>;
    }.bind(this));
    if(items != undefined ) return <div className="clearfix">{items}</div>;
  };

  addDivider(index){
    var last_item = this.props.items.length - 1;
    if(index != last_item){
      return <span className="divider" />
    }
  }

  addFlag(flag) {
    if (flag === true) {
      return <span className="red icon-flag"/>
    }
  }

  onClick(index) {
    this.props.onTabClick(index);
  }

  googleTrackingAction(){
    return 'Equity '+this.props.google_tracking+' Tabs'
  }
};
