import React from 'react';
import PropTypes from 'prop-types';
import withAnalyticsTracking from 'util/with_analytics_tracking';

class ModalTooltip extends React.Component {
  static propTypes = {
    content: PropTypes.oneOfType([PropTypes.element, PropTypes.string])
      .isRequired,
    className: PropTypes.string
  };

  static defaultProps = {
    className: ''
  };

  constructor(props) {
    super(props);
    this.triggerClicked = this.triggerClicked.bind(this);
  }

  trigger() {
    return (
      <span
        ref={ref => (this.triggerElement = ref)}
        onClick={this.triggerClicked}
      >
        {this.props.children}
      </span>
    );
  }

  triggerClicked() {
    if (this.remodal) {
      this.props.sendAnalyticsEvent();
      this.remodal.open();
    }
  }

  tooltipAndModalContent(cssClass) {
    if (typeof this.props.content === 'object') {
      return (
        <div
          className={cssClass}
          ref={el => {
            this.content = el;
          }}
        >
          {this.props.content}
        </div>
      );
    }
    return (
      <div
        className={cssClass}
        dangerouslySetInnerHTML={{ __html: this.props.content }}
        ref={el => {
          this.content = el;
        }}
      />
    );
  }

  render() {
    return (
      <div className={this.props.className}>
        {this.trigger()}
        <div style={{ display: 'none' }}>
          {this.tooltipAndModalContent('')}
          <div
            className="remodal modal_info_box"
            ref={el => {
              this.remodal = $(el).remodal();
            }}
          >
            <button data-remodal-action="close" className="remodal-close" />
            {this.tooltipAndModalContent('remodal-content')}
          </div>
        </div>
      </div>
    );
  }

  componentDidMount() {
    if (!('ontouchstart' in window)) {
      $(this.triggerElement).tipso({
        width: 300,
        onBeforeShow: (ele, tipso) => {
          this.remodal = null;
          $(this.triggerElement).tipso('update', 'content', this.content);
        },
        onShow: this.props.sendAnalyticsEvent,
        tooltipHover: true
      });
    }
  }
}

export default withAnalyticsTracking(ModalTooltip);
