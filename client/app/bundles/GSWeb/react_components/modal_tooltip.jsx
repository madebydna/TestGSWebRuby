import React from 'react';
import withAnalyticsTracking from 'util/with_analytics_tracking';

class ModalTooltip extends React.Component {
  static propTypes = {
    content: React.PropTypes.element
  }

  constructor(props) {
    super(props);
    this.triggerClicked = this.triggerClicked.bind(this);
  }

  trigger(){
    return <div ref={ref => this.triggerElement = ref} onClick={this.triggerClicked}>
      {this.props.children}
    </div>
  }

  triggerClicked() {
    if(this.remodal) {
      this.props.sendAnalyticsEvent();
      this.remodal.open();
    }
  }

  render() {
    return <div>
      {this.trigger()}
      <div style={{display: 'none'}}>
        <div ref={(el) => {this.content = el;}}>
          {this.props.content}
        </div>
        <div className="remodal modal_info_box" ref={(el) => {this.remodal = $(el).remodal()}}>
          <button data-remodal-action="close" className="remodal-close"></button>
          <div className="remodal-content">
            {this.props.content}
          </div>
        </div>
      </div>
    </div>
  }

  componentDidMount() {
    if(!('ontouchstart' in window)) {
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
