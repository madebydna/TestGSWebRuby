import React from 'react';

export default function(WrappedComponent, domEvent) {
  return React.createClass({
    sendAnalyticsEvent: function() {
      if(this.props.gaLabel && this.props.gaLabel != '') {
        analyticsEvent(this.props.gaCategory, this.props.gaAction, this.props.gaLabel);
      }
    },

    propTypes: {
      gaCategory: React.PropTypes.string,
      gaAction: React.PropTypes.string,
      gaLabel: React.PropTypes.string
    },

    getDefaultProps: function() {
      return {
        gaCategory: 'Profile',
        gaAction: 'Infobox'
      }
    },

    render: function() {
      let props = {
        sendAnalyticsEvent: this.sendAnalyticsEvent
      }
      if(domEvent) {
        props[domEvent] = this.sendAnalyticsEvent;
      }

      return <WrappedComponent {...props} {...this.props} />;
    }
  });
}
