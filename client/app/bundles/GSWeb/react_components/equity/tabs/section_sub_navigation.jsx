import React, { PropTypes } from 'react';

export default class SectionSubNavigation extends React.Component {
  render(){
    var active = this.props.active;
    var items = this.props.items.map(function(label, index) {
      return <a href="javascript:void(0)"
                key={index}
                className={'sub-nav-item js-gaClick' + (active === index ? ' sub-tab-selected' : '')}
                onClick={this.onClick.bind(this, index)}
                data-ga-click-category='Profile'
                data-ga-click-action='Equity Ethnicity Button'
                data-ga-click-label={label}>
        {label}
      </a>;
    }.bind(this));
    return <div className="sub-nav-group">{items}</div>;
  }

  onClick(index) {
    this.props.onTabClick(index);
  }
};
