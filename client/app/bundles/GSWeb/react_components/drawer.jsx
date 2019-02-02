import React from 'react';
import PropTypes from 'prop-types';
import { t } from '../util/i18n';
import createReactClass from 'create-react-class';

const Drawer = createReactClass({
  getInitialState: function() {
    return {
      open: false
    }
  },

  propTypes: {
    content: PropTypes.node.isRequired,
    openLabel: PropTypes.string,
    closedLabel: PropTypes.string,
    trackingCategory: PropTypes.string,
    trackingAction: PropTypes.string,
    trackingLabel: PropTypes.string
  },

  handleClick: function() {
    if(this.state.open) {
      analyticsEvent(this.props.trackingCategory, this.props.trackingAction+' Less', this.props.trackingLabel);
      // this.props.onClose.call();

      this.setState({open: false});
    } else {
      // this.props.onOpen.call();
      analyticsEvent(this.props.trackingCategory, this.props.trackingAction+' More', this.props.trackingLabel);
      this.setState({open: true});
    }
  },

  render: function() {
    let label;
    if (this.state.open) {
      label = this.props.openLabel || t('Show less');
    } else {
      label = this.props.closedLabel || t('Show more');
    }
    return(
      <div className={"show-more show-more--" + (this.state.open ? 'open' : 'closed')}>
        <div className="show-more__items " style={{display: 'block'}}>
          {(() => {
            if(this.state.open) {
              return this.props.content
            }
          })()}
        </div>
        <div className="show-more__button" onClick={this.handleClick}>
          { label }
        </div>
      </div>
    )
  }
});

export default Drawer;
