import React, { PropTypes } from 'react';

export default class SectionNavigation extends React.Component {
  render(){
    var active = this.props.active;
    var items = _.map(this.props.items, function(item, index) {
      return <div key={index} className="tab-container">
        <a href="javascript:void(0)"
                key={index}
                className={'tab-title js-gaClick' + (active === index ? ' tab-selected' : '')}
                onClick={this.onClick.bind(this, index)}
                data-ga-click-category='Profile'
                data-ga-click-action={this.googleTrackingAction()}
                data-ga-click-label={item.section_title}>
        {item.section_title}
      </a>
        {this.addDivider(index)}</div>;
    }.bind(this));
    if(items != undefined ) return <div className="clearfix space-below">{items}</div>;
  }

  addDivider(index){
    var last_item = this.props.items.length - 1;
    if(index != last_item){
      return <span className="divider">|</span>
    }
  }

  onClick(index) {
    this.props.onTabClick(index);
  }

  googleTrackingAction(){
    return 'Equity '+this.props.google_tracking+' Tabs'
  }
};
