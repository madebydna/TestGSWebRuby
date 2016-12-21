import React, { PropTypes } from 'react';

export default class SectionNavigation extends React.Component {
  render(){
    var active = this.props.active;

    var items = _.map(this.props.items, function(item, index) {
      return <a href="javascript:void(0)"
                key={index}
                className={'nav-title js-gaClick' + (active === index ? ' tab_selected' : '')}
                onClick={this.onClick.bind(this, index)}
                data-ga-click-category='Profile'
                data-ga-click-action={this.googleTrackingAction()}
                data-ga-click-label={item.section_title}>
        {item.section_title}
      </a>;
    }.bind(this));
    if(items != undefined ) return <div className="clearfix">{items}</div>;
  }

  onClick(index) {
    this.props.onTabClick(index);
  }

  googleTrackingAction(){
    return 'Equity '+this.props.google_tracking+' Tabs'
  }
};
