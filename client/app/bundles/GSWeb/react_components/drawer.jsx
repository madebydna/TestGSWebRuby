import React, { PropTypes } from 'react';
import { t } from '../util/i18n';

const Drawer = React.createClass({
  getInitialState: function() {
    return {
      open: false
    }
  },

  propTypes: {
    content: React.PropTypes.string.isRequired,
    openLabel: React.PropTypes.string,
    closedLabel: React.PropTypes.string,
    trackingCategory: React.PropTypes.string,
    trackingAction: React.PropTypes.string
  },

  handleClick: function() {
    if(this.state.open) {
      analyticsEvent(this.props.trackingCategory, this.props.trackingAction+' Less');
      // this.props.onClose.call();

      this.setState({open: false});
    } else {
      // this.props.onOpen.call();
      analyticsEvent(this.props.trackingCategory, this.props.trackingAction+' More' );
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
