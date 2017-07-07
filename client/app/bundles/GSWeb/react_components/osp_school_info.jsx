import React, { PropTypes } from 'react';
import SectionNavigation from './equity/tabs/section_navigation';
import ResponseData from './response_data.jsx';
import InfoCircle from './info_circle';
import AnchorButton from './anchor_button';
import GiveUsFeedback from './school_profiles/give_us_feedback'

export default class OspSchoolInfo extends React.Component {

  static propTypes = {
    content: PropTypes.array,
    source_name: PropTypes.string,
    qualaroo_module_link: PropTypes.string
  };

  constructor(props) {
    super(props);
    this.state = {
      activeTabIndex: 0
    }
  }

  handleTabClick(index) {
    this.setState({activeTabIndex: index})
  }

  selectSectionContent(items) {
    let item = items[this.state.activeTabIndex];
    let data = item.data;

    return <div className={'tabs-panel tabs-panel_selected'}>
      <ResponseData input={data}/>
    </div>
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

  footer(sources, qualaroo_module_link) {
    return (
        <div>
          { this.t('source') }:&nbsp;<span>{sources}</span>
          <GiveUsFeedback content={qualaroo_module_link} />
        </div>
    )
  }

  t() {
    if(GS && GS.I18n && GS.I18n.t) {
      return GS.I18n.t(...arguments);
    }
    return null;
  }

  render() {
    if (this.props.content ) {
      let stuff = this.props.content;
      let items = stuff.map((h) => ({section_title: h.title}));
      let infoText = 'Replace this with real copy';
      return (<div id="osp-school-info" data-ga-click-label="General Information">
        <a className="anchor-mobile-offset" name="General_info"/>
        <div className="equity-container">
          <div className="title-bar">
            <div className='rating-layout circle-rating--equity-blue'>
              <span className='icon-general-info'/>
            </div>
            <div className="title-container">
              <div className="title">
                { this.t('General Information') }
                <a data-remodal-target="modal_info_box"
                   data-content-type="info_box"
                   data-content-html={GS.I18n.t('general_information_tooltip')}
                   className="gs-tipso info-circle tipso_style" href="javascript:void(0)">
                  <span className="icon-question"></span>
                </a>
                <AnchorButton href={ this.props.osp_link } >{ this.t('edit') }</AnchorButton>
                <p><br /></p>
              </div>
            </div>
            <div className="tab-buttons">
              <SectionNavigation key="sectionNavigation"
                                 items={items}
                                 active={this.state.activeTabIndex}
                                 google_tracking={'General_info'}
                                 onTabClick={this.handleTabClick.bind(this)}/>
            </div>
            <div className="top-tab-panel">{this.selectSectionContent(stuff)}</div>

            <div className="source-bar">
              { this.footer(this.props.source_name, this.props.qualaroo_module_link) }
            </div>
          </div>
        </div>
      </div>)
    }
  }
}
