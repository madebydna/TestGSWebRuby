import React from 'react';
import withAnalyticsTracking from 'util/with_analytics_tracking';

class Remodal extends React.Component {
  static propTypes = {
    content: React.PropTypes.element
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
}

export default withAnalyticsTracking(Remodal);
