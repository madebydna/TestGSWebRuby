import React from 'react';
import PropTypes from 'prop-types';
import SectionNavigation from './equity/tabs/section_navigation';
import ResponseData from './response_data.jsx';
import InfoCircle from './info_circle';
import AnchorButton from './anchor_button';
import GiveUsFeedback from './school_profiles/give_us_feedback';
import { t } from '../util/i18n';
import BasicDataModuleLayout from 'react_components/school_profiles/basic_data_module_layout';
import { GeneralInfoIcon } from 'react_components/school_profiles/circle_icons';
import QuestionMarkTooltip from 'react_components/school_profiles/question_mark_tooltip';
import Calendar from 'react_components/community/calendar';
import ModuleTab from 'react_components/school_profiles/module_tab';
import Remodal from 'react_components/remodal';
import InfoBox from 'react_components/school_profiles/info_box';
import Sources from 'react_components/school_profiles/sources';

export default class OspSchoolInfo extends React.Component {
  static propTypes = {
    config: PropTypes.arrayOf(
      PropTypes.shape({
        key: PropTypes.string.isRequired,
        title: PropTypes.string.isRequired,
        data: PropTypes.arrayOf(
          PropTypes.shape({
            response_key: PropTypes.string.isRequired,
            response_value: PropTypes.arrayOf(PropTypes.string).isRequired
          })
        ).isRequired
      })
    ).isRequired,
    sources: Sources.propTypes.sources,
    qualaroo_module_link: PropTypes.string,
    is_claimed: PropTypes.bool.isRequired,
    has_osp_classes: PropTypes.bool.isRequired,
    has_non_osp_classes: PropTypes.bool.isRequired
  };

  static defaultProps = {};

  constructor(props) {
    super(props);
    this.state = {
      activeTabIndex: 0
    };
  }

  handleTabClick(index) {
    this.setState({ activeTabIndex: index });
  }

  configsWithData() {
    return this.props.config.filter(obj => obj.data);
  }

  selectSectionContent() {
    const configForActiveTab = this.configsWithData()[
      this.state.activeTabIndex
    ];

    if (configForActiveTab.key == 'overview') {
      return this.overviewPane();
    }

    if (configForActiveTab.key == 'classes') {
      return this.classesPane();
    }

    if (configForActiveTab.key == 'calendar') {
      return this.calendarPane();
    }

    return (
      this.shouldShowData() && <div className="tabs-panel tabs-panel_selected">
        <ResponseData input={configForActiveTab.data} />
      </div>
    );
  }

  overviewPane() {
    const configForActiveTab = this.configsWithData()[
      this.state.activeTabIndex
    ];

    if (!configForActiveTab.data || configForActiveTab.data.length < 1) {
      return null;
    }

    if (this.shouldShowData()){
      return <div className="tabs-panel tabs-panel_selected">
        <ResponseData input={configForActiveTab.data} />
      </div>;
    }else{
      return this.noDataCtaWithDescription();
    }
  }

  classesPane() {
    const configForActiveTab = this.configsWithData()[
      this.state.activeTabIndex
    ];
    if (!configForActiveTab.data || configForActiveTab.data.length < 1) {
      return null;
    }
    return (
      <div className="tabs-panel tabs-panel_selected">
        <ResponseData
          input={configForActiveTab.data}
          limit={this.props.is_claimed && this.props.has_osp_classes ? 0 : 1}
        />
        {!this.props.is_claimed && (
          <div>
            <hr />
            {this.noDataCta()}
          </div>
        )}
      </div>
    );
  }

  calendarPane(){
    const {nces_code, calendarURL, stateShort } = this.props.locality;
    const locality = {
      nces_code: nces_code,
      calendarURL: calendarURL,
      stateShort: stateShort
    }

    return <Calendar locality={locality} pageType={"SchoolProfiles"}/>
  }

  footer() {
    const qualaroo_module_link = this.props.qualaroo_module_link;
    const sourcesNode = <Sources sources={this.props.sources} />;
    return (
      <div>
        <Remodal
          gaLabel="General Information"
          gaElementType="sources"
          content={sourcesNode}
        >
          <a className="noTextDecoration" href="javascript:void(0)">
            <span className="source-link">
              <span className="icon-new-info" />
              {t('sources')}
            </span>
          </a>
        </Remodal>
        <GiveUsFeedback content={qualaroo_module_link} />
      </div>
    );
  }

  noDataCtaWithDescription() {
    return (
      <div className="ptm">
        <span
          className="no-data"
          dangerouslySetInnerHTML={{ __html: t('osp_school_info.subtitle') }}
        />
        <ul style={{ padding: '20px' }}>
          <li
            className="no-data"
            dangerouslySetInnerHTML={{
              __html: t('osp_school_info.bullet_1_html')
            }}
          />
          <li
            className="no-data"
            dangerouslySetInnerHTML={{
              __html: t('osp_school_info.bullet_2_html', {
                parameters: {
                  mailto_start: this.props.mailto_start,
                  mailto_end: this.props.mailto_end
                }
              })
            }}
          />
        </ul>
      </div>
    );
  }

  noDataCta() {
    return (
      <div className="ptm">
        <ul style={{ padding: '20px' }}>
          <li
            className="no-data"
            dangerouslySetInnerHTML={{
              __html: t('osp_school_info.bullet_1_html')
            }}
          />
          <li
            className="no-data"
            dangerouslySetInnerHTML={{
              __html: t('osp_school_info.bullet_2_html', {
                parameters: {
                  mailto_start: this.props.mailto_start,
                  mailto_end: this.props.mailto_end
                }
              })
            }}
          />
        </ul>
      </div>
    );
  }

  shouldShowData() {
    // this.props.has_non_osp_classes will always be undefined since
    // no props with that name is passed down
    // need to figure out if this goes here
    return (
      (this.props.is_claimed || this.props.has_non_osp_classes) &&
      this.props.config &&
      this.configsWithData().length > 0
    );
  }

  hasData() {
    return this.configsWithData().length > 0;
    // return (
    //   (this.props.is_claimed || this.props.has_non_osp_classes) &&
    //   this.props.config &&
    //   this.configsWithData().length > 0
    // );
  }

  r_t(key, replacements = {}) {
    let translated = this.props.i18n[key];
    Object.keys(replacements).forEach(key => {
      translated = translated.replace(`%{${key}}`, replacements[key]);
    });
    return translated;
  }

  render() {
    const titleElement = (
      <div>
        <h3 data-ga-click-label="General Information">
          {t('General Information')}
        </h3>
        &nbsp;
        {this.hasData() && (
          <QuestionMarkTooltip
            content={t('general_information_tooltip')}
            element_type="toptooltip"
          />
        )}
        <AnchorButton href={this.props.osp_link}>{t('edit')}</AnchorButton>
      </div>
    );

    const tabs = (
      <div className="tab-buttons">
        <SectionNavigation
          key="sectionNavigation"
          active={this.state.activeTabIndex}
          google_tracking="General_info"
          onTabClick={this.handleTabClick.bind(this)}
        >
          {this.props.config.map((obj, index) => (
            <ModuleTab {...obj} key={index} />
          ))}
        </SectionNavigation>
      </div>
    );

    return (
      <div id="osp-school-info" data-ga-click-label="General Information">
        <BasicDataModuleLayout
          share_content=""
          id="General_info"
          className="equity-container"
          icon={<GeneralInfoIcon />}
          title={titleElement}
          no_data_cta={!this.hasData() && this.noDataCtaWithDescription()}
          footer={this.hasData() && this.footer()}
          body={this.hasData() && <div>{this.selectSectionContent()}</div>}
          tabs={this.hasData() && tabs}
        />
      </div>
    );
  }
}
