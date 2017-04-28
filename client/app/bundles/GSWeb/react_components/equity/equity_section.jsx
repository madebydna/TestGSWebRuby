import React, { PropTypes } from 'react';
import InfoCircle from '../info_circle';
import SectionNavigation from './tabs/section_navigation';
import SubSectionToggle from './sub_section_toggle';

export default class EquitySection extends React.Component {

  static propTypes = {
    sources: React.PropTypes.string,
    equity_config: React.PropTypes.shape({
      section_info: React.PropTypes.object,
      section_content: React.PropTypes.arrayOf(React.PropTypes.shape({
        subject: React.PropTypes.string,
        component: React.PropTypes.object,
        explanation: React.PropTypes.element
      }))
    })
  };

  constructor(props) {
    super(props);
    this.state = {
      active: 0
    }
  }

  selectSectionContent(section_content) {
    let item = section_content[this.state.active];
    return <div className={'tabs-panel tabs-panel_selected'}>
      <SubSectionToggle
          key={this.state.active}
          equity_config={item["content"]}
      />
    </div>
  }
  drawRatingCircle(rating, icon) {
    let rating_html = '';
    if (rating && rating != '') {
      let circleClassName = 'circle-rating--medium rating-layout circle-rating--'+rating;
      rating_html = <div className={circleClassName}>{rating}<span className="rating-circle-small">/10</span></div>;
    }
    else{
      let circleClassName = 'rating-layout circle-rating--equity-blue';
      rating_html = <div className={circleClassName}><span className={icon}></span></div>;
    }
    return rating_html
  }

  drawInfoCircle(infoText) {
    if (infoText) {
      return(<InfoCircle
        content={infoText}
      />
      );
    } else {
      return null;
    }
  }

  linkName(name){
    return name.split(' ').join('_').replace('/', '_');
  }

  sectionTitle(sectionInfo) {
    var subtitle = '';
    var message = '';
    if (sectionInfo.subtitle) {
      subtitle = sectionInfo.subtitle;
    }
    if (sectionInfo.message) {
      message = sectionInfo.message;
    }
    return (
        <div className="title-container">
          <div className="title">
            {sectionInfo.title}
            {this.drawInfoCircle(sectionInfo.info_text)}
          </div>
          {subtitle}
          {message}
        </div>
    )
  }

  render() {
    let section_info = this.props.equity_config["section_info"];
    let section_content = this.props.equity_config["section_content"];
    let rating = this.drawRatingCircle(section_info.rating, section_info.icon_classes);
    let link_name = this.linkName(section_info.anchor);
    if (section_content) {
      return <div className="equity-section">
        <a className="anchor-mobile-offset" name={link_name}></a>
        <div className="title-bar">{rating}{this.sectionTitle(section_info)}</div>
        <div className="tab-buttons">
          <SectionNavigation key="sectionNavigation"
                           items={section_content}
                           active={this.state.active}
                           google_tracking={section_info.title}
                           onTabClick={this.handleTabClick.bind(this)}/>
        </div>
        <div className="top-tab-panel">{this.selectSectionContent(section_content)}</div>
        <a data-remodal-target="modal_info_box"
           data-content-type="info_box"
           data-content-html={this.props.sources}
           href="javascript:void(0)">
          <span className="source-link">{GS.I18n.t('See notes')}</span>
        </a>
      </div>
    }
    else {
      return <div className="equity-section">
        <a className="anchor-mobile-offset" name={link_name}></a>
        <div className="title-bar">{rating}{this.sectionTitle(section_info)}</div>
        </div>
    }
  }

  handleTabClick(index) {
    this.setState({active: index})
  }
};
