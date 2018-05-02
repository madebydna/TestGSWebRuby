import React from 'react';
import PropTypes from 'prop-types';
import withAnalyticsTracking from 'util/with_analytics_tracking';

class Remodal extends React.Component {
  static propTypes = {
    content: PropTypes.element
  };

  constructor(props) {
    super(props);
    this.triggerClicked = this.triggerClicked.bind(this);
  }

  trigger() {
    return React.cloneElement(this.props.children, {
      ref: ref => (this.triggerElement = ref),
      onClick: this.triggerClicked
    });
  }

  triggerClicked() {
    if (this.remodal) {
      this.props.sendAnalyticsEvent();
      this.remodal.open();
    }
  }

  render() {
    return (
      <React.Fragment>
        {this.trigger()}
        <div style={{ display: 'none' }}>
          <div
            ref={el => {
              this.content = el;
            }}
          >
            {this.props.content}
          </div>
          <div
            className="remodal modal_info_box"
            ref={el => {
              this.remodal = $(el).remodal();
            }}
          >
            <button data-remodal-action="close" className="remodal-close" />
            <div className="remodal-content">{this.props.content}</div>
          </div>
        </div>
      </React.Fragment>
    );
  }
}

export default withAnalyticsTracking(Remodal);
