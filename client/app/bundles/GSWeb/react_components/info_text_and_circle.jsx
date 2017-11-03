import React, { PropTypes } from 'react';

export default class InfoTextAndCircle extends React.Component {

  static propTypes = {
    cta: PropTypes.string.isRequired,
    content: PropTypes.string.isRequired,
    element_type: PropTypes.string.isRequired
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
         data-ga-click-element-type={this.props.element_type}
         data-content-html={this.props.content} className="speech-bubble" href="javascript:void(0)">
        {this.props.cta}
        <span className="info-circle icon-question"/>
      </a>
    </div>
    )
  };
}
