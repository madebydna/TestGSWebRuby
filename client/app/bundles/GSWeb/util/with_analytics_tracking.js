import React from 'react';
import PropTypes from 'prop-types';
import createReactClass from 'create-react-class';

export default function(WrappedComponent, domEvent) {
  return createReactClass({
    sendAnalyticsEvent() {
      if (this.props.gaLabel && this.props.gaLabel != '') {
        analyticsEvent(
          this.props.gaCategory,
          this.props.gaAction,
          this.getLabel()
        );
      }
    },

    propTypes: {
      gaCategory: PropTypes.string,
      gaAction: PropTypes.string,
      gaLabel: PropTypes.string,
      gaElementType: PropTypes.string
    },

    getDefaultProps() {
      return {
        gaCategory: 'Profile',
        gaAction: 'Infobox',
        gaElementType: null
      };
    },

    getLabel() {
      const elementDivider = ' - ';
      const elementType = this.props.gaElementType;
      const label = this.props.gaLabel;
      return elementType ? elementType + elementDivider + label : label;
    },

    render() {
      const props = {
        sendAnalyticsEvent: this.sendAnalyticsEvent
      };
      if (domEvent) {
        props[domEvent] = this.sendAnalyticsEvent;
      }

      return <WrappedComponent {...props} {...this.props} />;
    }
  });
}
