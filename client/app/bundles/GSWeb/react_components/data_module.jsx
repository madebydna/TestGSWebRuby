import React from 'react';
import PropTypes from 'prop-types';
import BarGraphBase from 'react_components/equity/graphs/bar_graph_base';
import TestScores from 'react_components/equity/graphs/test_scores';
import PersonBar from 'react_components/visualizations/person_bar';
import Circle from 'react_components/visualizations/circle';
import BasicDataModuleRow from 'react_components/school_profiles/basic_data_module_row';
import PlainNumber from 'react_components/equity/graphs/plain_number';
import RatingWithBar from 'react_components/equity/graphs/rating_with_bar';
import BarGraphCustomRanges from 'react_components/equity/graphs/bar_graph_custom_ranges';
import NoDataModuleCta from 'react_components/no_data_module_cta';
import InfoCircle from 'react_components/info_circle';
import InfoTextAndCircle from 'react_components/info_text_and_circle'
import SectionNavigation from 'react_components/equity/tabs/section_navigation';
import InfoBox from 'react_components/school_profiles/info_box';
import GiveUsFeedback from 'react_components/school_profiles/give_us_feedback';
import { t } from '../util/i18n';
import BasicDataModuleLayout from 'react_components/school_profiles/basic_data_module_layout';
import QuestionMarkTooltip from 'react_components/school_profiles/question_mark_tooltip';
import { handleAnchor, handleThirdAnchor, addAnchorChangeCallback, removeAnchorChangeCallback, formatAnchorString, formatAndJoinAnchors } from '../components/anchor_router';
import SectionSubNavigation from 'react_components/equity/tabs/section_sub_navigation';
import EquityContentPane from 'react_components/equity/equity_content_pane';
import TabsWithPanes from 'react_components/tabs_with_panes';
import ModuleTab from 'react_components/school_profiles/module_tab';
import ModuleSubTab from 'react_components/school_profiles/module_sub_tab';
import SharingModal from 'react_components/school_profiles/sharing_modal';

export default class DataModule extends React.Component {
  static propTypes = {
    title: PropTypes.string,
    anchor: PropTypes.string,
    subtitle: PropTypes.string,
    moduleOverview: PropTypes.object,
    info_text: PropTypes.string,
    sources: PropTypes.string,
    share_content: PropTypes.string,
    rating: PropTypes.number,
    data: PropTypes.arrayOf(PropTypes.shape({
      anchor: PropTypes.string,
      data: PropTypes.arrayOf(PropTypes.shape({
        title: PropTypes.string,
        anchor: PropTypes.string,
        type: PropTypes.string,
        values: PropTypes.oneOfType([
          PropTypes.array,
          PropTypes.object
        ]),
        narration: PropTypes.string,
        flagged: PropTypes.bool,
      })),
      title: PropTypes.string,
      flagged: PropTypes.bool,
      csa_badge: PropTypes.string
    })),
    analytics_id: PropTypes.string,
    showTabs: PropTypes.bool,
    faq: PropTypes.shape({
      cta: PropTypes.string.isRequired,
      content: PropTypes.string.isRequired,
      element_type: PropTypes.string.isRequired
    }),
    feedback: PropTypes.object,
    qualaroo_module_link: PropTypes.string,
    suppressIfEmpty: PropTypes.bool,
    footer: PropTypes.node,
    pageType: PropTypes.string
  };

  static defaultProps = {
    data: [],
    pageType: 'Profile'
  }

  constructor(props) {
    super(props);
    this.handleTabClick = this.handleTabClick.bind(this);
    this.selectInnerTabMatchingAnchor = this.selectInnerTabMatchingAnchor.bind(this);
    this.state = {
      active: 0,
      activeInnerTab: 0
    }
  }

  componentDidMount() {
    this.selectTabMatchingAnchor(() => this.selectInnerTabMatchingAnchor());
    addAnchorChangeCallback(() => this.selectTabMatchingAnchor());
    addAnchorChangeCallback(() => this.selectInnerTabMatchingAnchor());
  }

  componentWillUnmount() {
    removeAnchorChangeCallback(() => this.selectTabMatchingAnchor());
    removeAnchorChangeCallback(() => this.selectInnerTabMatchingAnchor());
  }

  selectTabMatchingAnchor(callback) {
    let tabAnchors = this.filteredData().map(data => data.anchor)
    handleAnchor(
      this.props.anchor, tokens => {
        let index = tabAnchors.findIndex((anchor) => anchor == tokens[0]);
        if(index == -1) {
          index = 0;
        }
        this.setState({ active: index }, callback);
      }
    );
  }

  selectInnerTabMatchingAnchor() {
    let dataForActiveTab = this.filteredData()[this.state.active];
    if(!dataForActiveTab) return null;
    let anchors = dataForActiveTab.data.map(({anchor} = {}) => anchor);

    handleThirdAnchor(
      formatAnchorString(dataForActiveTab.anchor), tokens => {
        let index = anchors.findIndex((anchor = '') => {
          return anchor.replace(/\s/g, "_") == tokens[0];
        });
        if(index > -1) {
          this.setState({ activeInnerTab: index });
        }
      }
    );
  }

  filteredData() {
    return this.props.data.filter(o => o.data && o.data.length > 0)
  }

  hasData() {
    return this.filteredData().length > 0
  }

  wrapGraphComponent(graphComponent, value, index) {
    return <div><BasicDataModuleRow {...value} key={index.toString() + this.state.active}>
      {graphComponent}
    </BasicDataModuleRow></div>;
  }


  createDataComponent(type, values) {
    if (values) {
      // This is for titles in the test scores
      if(!(values instanceof Array)){
        return <TestScores test_scores={values}/>;
      }

      if (values.length > 0) {
        let display_type = type || 'bar';
        let component = [];
        if (display_type == 'plain') {
          component = <PlainNumber values={values}/>
        } else if (display_type == 'person') {
          component = <div>
            {values.map((value, index) =>
              <BasicDataModuleRow {...value} key={index.toString() + this.state.active}>
                <PersonBar {...value} />
              </BasicDataModuleRow>)
            }
          </div>
        } else if (display_type == 'person_reversed') {
          component = <div>
            {values.map((value, index) =>
              <BasicDataModuleRow {...value} key={index.toString() + this.state.active}>
                <PersonBar {...value} invertedRatings={true} />
              </BasicDataModuleRow>)
            }
          </div>
        } else if (display_type == 'rating') {
          component = <div>
            {values.map((value, index) =>
              <BasicDataModuleRow {...value} key={index.toString() + this.state.active}>
                <RatingWithBar {...value} />
              </BasicDataModuleRow>)
            }
          </div>
        } else if (display_type == 'person_gray') {
          component = <div>
            {values.map((value, index) =>
              <BasicDataModuleRow {...value} key={index.toString() + this.state.active}>
                <PersonBar {...value} use_gray={true}/>
              </BasicDataModuleRow>)
            }
          </div>
        } else if (display_type == 'circle') {
          component = <div>
            {values.map((value, index) =>
              <Circle {...value} key={index.toString() + this.state.active} />)
            }
          </div>
        } else if (display_type == 'mixed_variety'){
          component = this.createMixedDataComponent(values);
        } else if (display_type == 'bar_custom_range'){
          component = <div>
            {values.map((value, index) =>
              <BasicDataModuleRow {...value} key={index.toString() + this.state.active}>
                <BarGraphCustomRanges {...value} />
              </BasicDataModuleRow>)
            }
          </div>
        } else {
          component = <div>
            {values.map((value, index) =>
              <BasicDataModuleRow {...value} key={index.toString() + this.state.active}>
                <BarGraphBase {...value} />
              </BasicDataModuleRow>)
            }
          </div>
        }
        return component;
      }
    }
    return null;
  }

  createMixedDataComponent(values){
    let customScoreRanges = ["Average SAT score", "Calificación media de los SAT", "Average ACT score", "Calificación media de ACT"];
    let dataRows = <div>
      {values.map((value,index) => {
        if (customScoreRanges.indexOf(value.breakdown) >= 0){
          return <BasicDataModuleRow {...value} key={index.toString() + this.state.active}>
                  <BarGraphCustomRanges {...value} />
                 </BasicDataModuleRow>;
        }else{
          switch (value.display_type){
            case 'plain':
              return <BasicDataModuleRow {...value} key={index.toString() + this.state.active}>
                      <PlainNumber {...value} />
                     </BasicDataModuleRow>;
            case 'person':
              return <BasicDataModuleRow {...value} key={index.toString() + this.state.active}>
                       <PersonBar {...value} />
                     </BasicDataModuleRow>;
            case 'person reversed':
              return <BasicDataModuleRow {...value} key={index.toString() + this.state.active}>
                       <PersonBar {...value} invertedRatings={true} />
                     </BasicDataModuleRow>;
            case 'person_gray':
              return <BasicDataModuleRow {...value} key={index.toString() + this.state.active}>
                       <PersonBar {...value} use_gray={true} />
                     </BasicDataModuleRow>;
            case 'rating':
              return <BasicDataModuleRow {...value} key={index.toString() + this.state.active}>
                       <RatingWithBar {...value} />
                     </BasicDataModuleRow>;
            default:
              return <BasicDataModuleRow {...value} key={index.toString() + this.state.active}>
                       <BarGraphBase {...value} />
                     </BasicDataModuleRow>;
          }
        }
      })}
    </div>
    return dataRows;
  }

  handleTabClick(index) {
    this.setState({active: index, activeInnerTab: 0});
  }

  icon() {
    let rating = this.props.rating;
    let rating_html = '';
    if (rating && rating != '') {
      let circleClassName = 'circle-rating--medium circle-rating--'+rating;
      rating_html = <div className={circleClassName}>{rating}<span className="rating-circle-small">/10</span></div>;
    } else {
      if (typeof this.props.icon_classes === 'string') {
        let circleClassName = 'circle-rating--equity-blue';
        rating_html = <div className={circleClassName}><span className={this.props.icon_classes}></span></div>;
      } else {
        rating_html = this.props.icon_classes;
      }
    }
    return rating_html
  }

  title() {
    return (
      <div  data-ga-click-label={this.props.title}>
        <h3>{this.props.title}</h3>&nbsp;
        { this.props.info_text &&
          <QuestionMarkTooltip content={this.props.info_text} element_type='toptooltip' /> }
      </div>
    )
  }

  activePane() {
    let dataForActiveTab = this.filteredData()[this.state.active];

    // if `item.title` is undefined, then the pane buttons will not appear
    let subTabs = dataForActiveTab.data.map((item, index) => {
      let anchorLink = formatAndJoinAnchors(this.props.anchor, dataForActiveTab.anchor, item.anchor)
      return <ModuleSubTab {...item} key={index} anchorLink={anchorLink} pageType={this.props.pageType} />
    });

    let subNav;
    // in case there is a single subTab we should display it unless its title is the same as the main tab's title
    if (subTabs.length > 1 ||
        subTabs.length == 1 &&
          dataForActiveTab.title &&
          dataForActiveTab.data[0] &&
          dataForActiveTab.data[0].title &&
          dataForActiveTab.title !== dataForActiveTab.data[0].title) {
      subNav = <SectionSubNavigation key={this.state.active}>
        {subTabs}
      </SectionSubNavigation>
    }

    let subPanes = dataForActiveTab.data.map(({anchor, type, values, narration} = {}) => {
      let explanation = <div dangerouslySetInnerHTML={{__html: narration}} />
        return (
          <EquityContentPane
            anchor={anchor}
            graph={this.createDataComponent(type, values)}
            text={explanation}
          />
        );
    })

    return (
      <div data-ga-click-label={this.props.title}>
        <div className={'tabs-panel tabs-panel_selected'}>
          <TabsWithPanes
            key={this.state.active}
            active={this.state.activeInnerTab}
            tabsContainer={subNav}
            panes={subPanes}
          />
        </div>
        {this.props.faq && <InfoTextAndCircle {...this.props.faq} />}
      </div>
    )
  }

  tabs() {
    return this.filteredData().map(function (item, index) {
      let anchorLink;
      if(item.anchor){
        anchorLink = formatAndJoinAnchors(this.props.anchor, item.anchor);
      }
      let badge = item.csa_badge;
      return <ModuleTab {...item} key={index} anchorLink={anchorLink} badge={badge} pageType={this.props.pageType} />
    }.bind(this))
  }

  tabsContainer() {
    return (
      <div className="tab-buttons">
        <SectionNavigation active={this.state.active} onTabClick={this.handleTabClick} badge={this.props.csa_badge} >
          { this.tabs() }
        </SectionNavigation>
      </div>
    )
  }

  defaultFooter() {
    return (
      <div data-ga-click-label={this.props.title}>
        <InfoBox content={this.props.sources} element_type="sources" pageType={this.props.pageType}>{ t('See notes') }</InfoBox>
        {this.props.qualaroo_module_link && <GiveUsFeedback content={this.props.qualaroo_module_link} />}
      </div>
    )
  }

  noDataCta() {
    return <NoDataModuleCta moduleName={this.props.title} message={this.props.no_data_summary} />
  }

  handleRender(){
    let analyticsId = this.props.analytics_id;
    if (!this.hasData()) {
      analyticsId += '-empty'; // no data
    }
    let { suppressIfEmpty } = this.props;
    if (!this.hasData() && suppressIfEmpty) {
      return null;
    }
    return (
      <div id={analyticsId}>
      <BasicDataModuleLayout
        sharing_modal={ this.hasData() && this.props.share_content &&
        <SharingModal content={this.props.share_content}/> }
        id={this.props.anchor}
        className=''
        icon={ this.icon() }
        title={ this.title() }
        subtitle={ this.props.subtitle }
        moduleOverview={ this.props.moduleOverview }
        no_data_cta={ !this.hasData() && this.noDataCta() }
        footer={ this.hasData() && (this.props.footer || this.defaultFooter()) }
        body={ this.hasData() && this.activePane() }
        tabs={ this.hasData() && this.tabsContainer() }
      />
    </div>
    )

  }

  render() {
    return (
      this.handleRender()
    )
  }
};
