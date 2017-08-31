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

  footer(sources, qualaroo_module_link) {
    return (
      <div>
        { t('source') }:&nbsp;<span>{sources}</span>
        <GiveUsFeedback content={qualaroo_module_link} />
      </div>
    )
  }

  render() {
    if (this.props.content ) {
      let stuff = this.props.content;
      let items = stuff.map((h) => ({title: h.title}));
      let titleElement = <div>
        { t('General Information') }
        &nbsp;<QuestionMarkTooltip content={t('general_information_tooltip')} />
        <AnchorButton href={ this.props.osp_link } >{ t('edit') }</AnchorButton>
      </div>

      let tabs = <div className="tab-buttons">
        <SectionNavigation key="sectionNavigation"
          items={items}
          active={this.state.activeTabIndex}
          google_tracking={'General_info'}
          onTabClick={this.handleTabClick.bind(this)}/>
      </div>

      return (
        <div id="osp-school-info" data-ga-click-label="General Information">
        <BasicDataModuleLayout
          id = 'General_info'
          className='equity-container'
          icon = { <GeneralInfoIcon/> }
          title = { titleElement }
          footer = { this.footer(this.props.source_name, this.props.qualaroo_module_link) }
          body = { <div>{this.selectSectionContent(stuff)}</div> }
          tabs = { tabs }
        />
      </div>
      )
    } else {
      return (<div/>)
    }
  }
}
