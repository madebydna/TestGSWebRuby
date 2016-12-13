import React, { PropTypes } from 'react';

export default class InfoCircle extends React.Component {
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
      <a data-remodal-target="modal_info_box"
        data-content-type="info_box"
        data-content-html={this.props.content}
        className="gs-tipso info-circle"
        href="javascript:void(0)">
          <span className="icon-hint"></span>
      </a>
    )
  };
}

InfoCircle.propTypes = {
  content: React.PropTypes.string.isRequired
};
