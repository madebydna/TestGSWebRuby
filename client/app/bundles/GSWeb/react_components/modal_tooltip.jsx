import React from 'react';
import ReactModal from 'react-modal';
import withAnalyticsTracking from 'util/with_analytics_tracking';

class ModalTooltip extends React.Component {
  static propTypes = {
    content: React.PropTypes.element
  }

  constructor(props) {
    super(props);
    this.trigger = this.trigger.bind(this);
    this.triggerClicked = this.triggerClicked.bind(this);
  }

  trigger(){
    return <div ref={ref => this.triggerRef = ref} onClick={this.triggerClicked}>
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
        <div ref={(r) => {this.content = r;}}>
          {this.props.content}
        </div>
        <div className="remodal modal_info_box" ref={(m) => {this.remodal = $(m).remodal()}}>
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
      $(this.triggerRef).tipso({
        width: 300,
        onBeforeShow: (ele, tipso) => {
          this.remodal = null;
          $(this.triggerRef).tipso('update', 'content', this.content);
        },
        onShow: this.props.sendAnalyticsEvent,
        tooltipHover: true
      });
    }
  }
}

export default withAnalyticsTracking(ModalTooltip);
