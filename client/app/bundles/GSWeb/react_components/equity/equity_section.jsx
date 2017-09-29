import React, { PropTypes } from 'react';
import InfoCircle from '../info_circle';
import InfoTextAndCircle from '../info_text_and_circle'
import SectionNavigation from './tabs/section_navigation';
import SubSectionToggle from './sub_section_toggle';
import InfoBox from '../school_profiles/info_box';
import GiveUsFeedback from '../school_profiles/give_us_feedback';
import { t } from '../../util/i18n';

import { handleAnchor, addAnchorChangeCallback, removeAnchorChangeCallback, formatAnchorString } from '../../components/anchor_router';

export default class EquitySection extends React.Component {

  static propTypes = {
    title: React.PropTypes.string,
    anchor: React.PropTypes.string,
    subtitle: React.PropTypes.object,
    info_text: React.PropTypes.string,
    icon_classes: React.PropTypes.string,
    sources: React.PropTypes.string,
    share_content: React.PropTypes.string,
    rating: React.PropTypes.number,
    message: React.PropTypes.string,
    qualaroo_module_link: React.PropTypes.string,
    no_data_summary: React.PropTypes.string,
    section_content: React.PropTypes.arrayOf(React.PropTypes.shape({
      subject: React.PropTypes.string,
      component: React.PropTypes.object,
      explanation: React.PropTypes.element
    })),
    faq: PropTypes.shape({
      cta: PropTypes.string.isRequired,
      content: PropTypes.string.isRequired
    })
  };

  constructor(props) {
    super(props);
    this.state = {
      active: 0,
      defaultSubSectionTab: null
    }
  }

  footer(sources, qualaroo_module_link) {
    return (
      <div className="module-footer">
        <InfoBox content={sources} >{ t('See notes') }</InfoBox>
        <GiveUsFeedback content={qualaroo_module_link} />
      </div>
    )
  }

  sharingModal() {
    return (
        <button>
          <a data-remodal-target="modal_info_box"
           data-content-type="info_box"
           data-content-html={this.props.share_content}
           className="gs-tipso"
           data-tipso-width="318"
           data-tipso-position="left"
           href="javascript:void(0)">
            <div className="dib">
              {t('Share')}
            </div>
          </a>
        </button>
    )
  }

  selectTabMatchingAnchor() {
    handleAnchor(
      this.props.anchor, tokens => {
        let section_content = this.props.section_content;
        let index = section_content.findIndex((content) => content["anchor"] == tokens[0]);
        if(index == -1) {
          index = 0;
        }
        this.setState({ active: index });
      }
    );
  }

  componentDidMount() {
    this.selectTabMatchingAnchor();
    addAnchorChangeCallback(() => this.selectTabMatchingAnchor());
  }

  componentWillUnmount() {
    removeAnchorChangeCallback(() => this.selectTabMatchingAnchor());
  }

  selectSectionContent(section_content) {
    let item = section_content[this.state.active];
    return <div className={'tabs-panel tabs-panel_selected'}>
      <SubSectionToggle
          defaultTab={this.state.defaultSubSectionTab}
          key={this.state.active}
          equity_config={item["content"]}
          anchor={item.anchor}
          top_anchor={formatAnchorString(this.props.anchor)}
          parent_anchor={this.props.section_content[this.state.active].anchor}
      />
    </div>
  }
  drawRatingCircle(rating, icon) {
    let rating_html = '';
    if (rating && rating != '') {
      let circleClassName = 'circle-rating--medium circle-rating--'+rating;
      rating_html = <div className={circleClassName}>{rating}<span className="rating-circle-small">/10</span></div>;
    }
    else{
      let circleClassName = 'circle-rating--equity-blue';
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

  sectionTitle() {
    return (
      <div className="title-container">
        <div>
          <span className="title">{this.props.title}</span>&nbsp;
          {this.drawInfoCircle(this.props.info_text)}
        </div>
        {this.props.subtitle}
        {this.props.message}
      </div>
    )
  }

  render() {
    let { title, anchor, rating, icon_classes, section_content } = this.props;
    let ratingCircle = this.drawRatingCircle(rating, icon_classes);
    let link_name = formatAnchorString(anchor);
    if (section_content) {
      return <div className="rating-container" data-ga-click-label={title}>
        <a className="anchor-mobile-offset" name={link_name}></a>
        <div className="profile-module">
          <div className="module-header">
            <div className="row">
              <div className="col-xs-12 col-md-10">
                {ratingCircle}{this.sectionTitle()}
              </div>
              <div className="col-xs-12 col-md-2 show-history-button">
                <div>
                  {this.sharingModal()}
                </div>
              </div>
            </div>
          </div>
          <div className="tab-buttons">
            <SectionNavigation
              parent_anchor={link_name}
              key="sectionNavigation"
              items={section_content}
              active={this.state.active}
              google_tracking={title}
              onTabClick={this.handleTabClick.bind(this)}
            />
          </div>
          <div className="panel">
            {this.selectSectionContent(section_content)}
            <InfoTextAndCircle {...this.props.faq} />
          </div>
          { this.footer(this.props.sources, this.props.qualaroo_module_link) }
        </div>
      </div>
    }
    else {
      return <div className="rating-container">
        <a className="anchor-mobile-offset" name={link_name}></a>
        <div className="profile-module">
          <div className="module-header">{ratingCircle}{this.sectionTitle()}</div>
        </div>
      </div>
    }
  }

  handleTabClick(index) {
    this.setState({active: index})
  }
};
