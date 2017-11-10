import React from 'react';
import withAnalyticsTracking from 'util/with_analytics_tracking';

class ModalTooltip extends React.Component {
  static propTypes = {
    content: React.PropTypes.element,
    className: React.PropTypes.string
  }

  constructor(props) {
    super(props);
    this.triggerClicked = this.triggerClicked.bind(this);
  }

  trigger(){
    return <span ref={ref => this.triggerElement = ref} onClick={this.triggerClicked}>
      {this.props.children}
    </span>
  }

  triggerClicked() {
    if(this.remodal) {
      this.props.sendAnalyticsEvent();
      this.remodal.open();
    }
  }

  render() {
    return <div className={this.props.className}>
      {this.trigger()}
      <div style={{display: 'none'}}>
        <div dangerouslySetInnerHTML={{__html: this.props.content}} ref={(el) => {this.content = el;}}>
        </div>
        <div className="remodal modal_info_box" ref={(el) => {this.remodal = $(el).remodal()}}>
          <button data-remodal-action="close" className="remodal-close"></button>
          <div dangerouslySetInnerHTML={{__html: this.props.content}} className="remodal-content">
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
