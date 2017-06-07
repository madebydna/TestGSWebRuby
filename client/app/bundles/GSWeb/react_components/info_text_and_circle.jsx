import React, { PropTypes } from 'react';

export default class InfoTextAndCircle extends React.Component {

  static propTypes = {
    cta: React.PropTypes.string.isRequired,
    content: React.PropTypes.string.isRequired
  };

  constructor(props) {
    super(props);
  }

  componentDidMount() {
    if(GS && GS.tooltip) {
      GS.tooltip.initialize();
    }
  }

  render() {
    return(
    <div className="info-text-and-circle">
      <a data-remodal-target="modal_info_box" data-content-type="info_box"
         data-content-html={this.props.content} className="speech-bubble gs-tipso" href="javascript:void(0)">
        {this.props.cta}
        <span className="info-circle icon-question"/>
      </a>
    </div>
    )
  };
}
