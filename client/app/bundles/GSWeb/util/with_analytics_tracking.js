import React from 'react';
import PropTypes from 'prop-types';
import createReactClass from 'create-react-class';

export default function(WrappedComponent, domEvent) {
  return createReactClass({
    sendAnalyticsEvent: function() {
      if(this.props.gaLabel && this.props.gaLabel != '') {
        analyticsEvent(this.props.gaCategory, this.props.gaAction, this.props.gaLabel);
      }
    },

    propTypes: {
      gaCategory: PropTypes.string,
      gaAction: PropTypes.string,
      gaLabel: PropTypes.string
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
