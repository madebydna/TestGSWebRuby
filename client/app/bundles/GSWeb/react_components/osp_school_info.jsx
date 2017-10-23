import React, { PropTypes } from 'react';
import SectionNavigation from './equity/tabs/section_navigation';
import ResponseData from './response_data.jsx';
import InfoCircle from './info_circle';
import AnchorButton from './anchor_button';
import GiveUsFeedback from './school_profiles/give_us_feedback'
import { t } from '../util/i18n';
import BasicDataModuleLayout from 'react_components/school_profiles/basic_data_module_layout';
import { GeneralInfoIcon } from 'react_components/school_profiles/circle_icons';
import QuestionMarkTooltip from 'react_components/school_profiles/question_mark_tooltip';
import ModuleTab from 'react_components/school_profiles/module_tab';

export default class OspSchoolInfo extends React.Component {

  static propTypes = {
    config: PropTypes.arrayOf(PropTypes.shape({
      key: PropTypes.string.isRequired,
      title: PropTypes.string.isRequired,
      data: PropTypes.arrayOf(PropTypes.shape({
        response_key: PropTypes.string.isRequired,
        response_value: PropTypes.arrayOf(PropTypes.string).isRequired
      })).isRequired
    })).isRequired,
    source_name: PropTypes.string,
    qualaroo_module_link: PropTypes.string,
    is_claimed: PropTypes.bool.isRequired,
    has_osp_classes: PropTypes.bool.isRequired
  };

  static defaultProps = {}

  constructor(props) {
    super(props);
    this.state = {
      activeTabIndex: 0
    }
  }

  handleTabClick(index) {
    this.setState({activeTabIndex: index})
  }

  configsWithData() {
    return this.props.config.filter(obj => obj.data)
  }

  selectSectionContent() {
    let configForActiveTab = this.configsWithData()[this.state.activeTabIndex];

    if(configForActiveTab.key == 'classes') {
      return this.classesPane();
    } 

    return <div className={'tabs-panel tabs-panel_selected'}>
      <ResponseData input={configForActiveTab.data}/>
    </div>
  }

  classesPane() {
    let configForActiveTab = this.configsWithData()[this.state.activeTabIndex];
    if(!configForActiveTab.data || configForActiveTab.data.length < 1) {
      return null;
    }
    return <div className={'tabs-panel tabs-panel_selected'}>
      <ResponseData input={configForActiveTab.data} limit={1}/>
      { !this.props.is_claimed && !this.props.has_osp_classes && <div><hr/>{ this.noDataCta() }</div> }
    </div>
  }

  footer(sources, qualaroo_module_link) {
    return (
      <div>
        { t('source') }:&nbsp;<span>{sources}</span>
        <GiveUsFeedback content={qualaroo_module_link} />
      </div>
    )
  }

  noDataCta() {
    return <div className="ptm">
      <span className="no-data" dangerouslySetInnerHTML={{__html: t('osp_school_info.subtitle')}}></span>
      <ul style={{padding: '20px'}}>
        <li className="no-data" dangerouslySetInnerHTML={{__html: t('osp_school_info.bullet_1_html')}}></li>
        <li className="no-data" dangerouslySetInnerHTML={{__html: t('osp_school_info.bullet_2_html', {parameters: { mailto_start: this.props.mailto_start, mailto_end: this.props.mailto_end}})}}></li>
      </ul>
    </div>
  }

  hasData() {
    return (this.props.is_claimed || this.props.has_osp_classes) && this.props.config && this.configsWithData().length > 0;
  }

  r_t(key, replacements = {}) {
    let translated = this.props.i18n[key];
    Object.keys(replacements).forEach((key) => {
      translated = translated.replace('%{' + key + '}', replacements[key]);
    })
    return translated;
  }

  render() {
    let titleElement = <div>
      { t('General Information') }
      &nbsp;<QuestionMarkTooltip content={t('general_information_tooltip')} />
      <AnchorButton href={ this.props.osp_link } >{ t('edit') }</AnchorButton>
    </div>

    let tabs = <div className="tab-buttons">
      <SectionNavigation key="sectionNavigation"
        active={this.state.activeTabIndex}
        google_tracking={'General_info'}
        onTabClick={this.handleTabClick.bind(this)}>
        {this.props.config.map((obj, index) => <ModuleTab {...obj} key={index} />)}
      </SectionNavigation>
    </div>

    return (
      <div id="osp-school-info" data-ga-click-label="General Information">
        <BasicDataModuleLayout
          share_content=""
          id = 'General_info'
          className='equity-container'
          icon = { <GeneralInfoIcon/> }
          title = { titleElement }
          no_data_cta={ !this.hasData() && this.noDataCta() }
          footer = { this.footer(this.props.source_name, this.props.qualaroo_module_link) }
          body = { this.hasData() && <div>{this.selectSectionContent()}</div> }
          tabs = { this.hasData() && tabs }
        />
      </div>
    )
  }
}
