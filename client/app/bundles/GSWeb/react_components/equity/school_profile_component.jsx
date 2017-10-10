import React, { PropTypes } from 'react';
import BarGraphBase from './graphs/bar_graph_base';
import TestScores from './graphs/test_scores';
import PersonBar from '../visualizations/person_bar';
import BasicDataModuleRow from '../school_profiles/basic_data_module_row';
import PlainNumber from './graphs/plain_number';
import RatingWithBar from './graphs/rating_with_bar';
import NoDataModuleCta from '../no_data_module_cta';
import InfoCircle from '../info_circle';
import InfoTextAndCircle from '../info_text_and_circle'
import SectionNavigation from './tabs/section_navigation';
import SubSectionToggle from './sub_section_toggle';
import InfoBox from '../school_profiles/info_box';
import GiveUsFeedback from '../school_profiles/give_us_feedback';
import { t } from '../../util/i18n';
import BasicDataModuleLayout from 'react_components/school_profiles/basic_data_module_layout';
import QuestionMarkTooltip from 'react_components/school_profiles/question_mark_tooltip';
import { handleAnchor, handleThirdAnchor, addAnchorChangeCallback, removeAnchorChangeCallback, formatAnchorString, hashSeparatorAnchor } from '../../components/anchor_router';
import SectionSubNavigation from './tabs/section_sub_navigation';
import EquityContentPane from './equity_content_pane';
import TabsWithPanes from 'react_components/tabs_with_panes';

export default class SchoolProfileComponent extends React.Component {
  static propTypes = {
    title: PropTypes.string,
    anchor: PropTypes.string,
    subtitle:  PropTypes.string,
    info_text: PropTypes.string,
    icon_classes: PropTypes.string,
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
        flagged: PropTypes.bool
      })),
      title: PropTypes.string,
      flagged: PropTypes.bool
    })),
    analytics_id: PropTypes.string,
    faq: PropTypes.shape({
      cta: PropTypes.string.isRequired,
      content: PropTypes.string.isRequired
    }),
    qualaroo_module_link: PropTypes.string
  };

  static defaultProps = {
    data: []
  }

  constructor(props) {
    super(props);
    this.selectInnerTabMatchingAnchor = this.selectInnerTabMatchingAnchor.bind(this);
    this.state = {
      active: 0,
      activeInnerTab: 0
    }
  }

  componentDidMount() {
    this.selectTabMatchingAnchor();
    addAnchorChangeCallback(() => this.selectTabMatchingAnchor());
  }

  componentWillUnmount() {
    removeAnchorChangeCallback(() => this.selectTabMatchingAnchor());
  }

  selectTabMatchingAnchor() {
    let tabAnchors = this.filteredData().map(data => data.anchor)
    handleAnchor(
      this.props.anchor, tokens => {
        let index = tabAnchors.findIndex((anchor) => anchor == tokens[0]);
        if(index == -1) {
          index = 0;
        }
        this.setState({ active: index });
      }
    );
  }

  selectInnerTabMatchingAnchor() {
    let dataForActiveTab = this.filteredData()[this.state.active];
    if(!dataForActiveTab) return null;

    handleThirdAnchor(
      formatAnchorString(dataForActiveTab.anchor), tokens => {
        let index = this.panes().findIndex((pane) => {
          let anchor = pane.props.children[1].props.anchor;
          if(anchor) {
            anchor = anchor.replace(/\s/g, "_");
          }
          return anchor == tokens[0];
        });
        if(index != -1) {
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

  createDataComponent(type, values) {
    if (values) {
      // This is for titles in the test scores
      if(!(values instanceof Array)){
        return <TestScores test_scores={values}/>;
      }

      if (values.length > 0) {
        let displayType = type || 'bar';
        let component = null;
        if (displayType == 'plain') {
          component = <PlainNumber values={values}/>
        } else if (displayType == 'person') {
          component = <div>
            {values.map((value, index) => 
              <BasicDataModuleRow {...value} key={index}>
                <PersonBar {...value} />
              </BasicDataModuleRow>)
            }
          </div>
        } else if (displayType == 'person_reversed') {
          component = <div>
            {values.map((value, index) => 
              <BasicDataModuleRow {...value} key={index}>
                <PersonBar {...value} invertedRatings={true} />
              </BasicDataModuleRow>)
            }
          </div>
        } else if (displayType == 'rating') {
          component = <div>
            {values.map((value, index) =>
                <BasicDataModuleRow {...value} key={index}>
                  <RatingWithBar {...value} />
                </BasicDataModuleRow>)
            }
          </div>
        } else {
          component = <div>
            {values.map((value, index) => 
              <BasicDataModuleRow {...value} key={index}>
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

  handleTabClick(index) {
    this.setState({active: index, activeInnerTab: 0})
  }

  handleInnerTabClick(index) {
    this.setState({activeInnerTab: index})
  }

  sectionNavigationTabs() {
    return this.filteredData().map(function(item, index) {
      let anchorLink = '';
      let addJSHashUpdate = '';
      if(item.anchor){
        addJSHashUpdate = ' js-updateLocationHash';
        anchorLink = formatAnchorString(this.props.anchor) + hashSeparatorAnchor() + formatAnchorString(item.anchor);
      }
      return (
        <a href="javascript:void(0)"
          data-anchor={anchorLink}
          key={index}
          className={'tab-title js-gaClick' + addJSHashUpdate}
          onClick={this.handleTabClick.bind(this, index)}
          data-ga-click-category='Profile'
          data-ga-click-action={this.googleTrackingAction()}
          data-ga-click-label={item.title}>
          {item.title}
          {item.flagged && <span className="red icon-flag"/>}
        </a>
      )
    }.bind(this));
  }

  googleTrackingAction(){
    return 'Equity '+this.props.google_tracking+' Tabs'
  }

  sharingModal() {
    return (
      <a data-remodal-target="modal_info_box"
        data-content-type="info_box"
        data-content-html={this.props.share_content}
        className="share-link gs-tipso"
        data-tipso-width="318"
        data-tipso-position="left"
        href="javascript:void(0)">
        <span className="icon-share"></span>&nbsp;
        {t('Share')}
      </a>
    )
  }

  icon() {
    let rating = this.props.rating;
    let rating_html = '';
    if (rating && rating != '') {
      let circleClassName = 'circle-rating--medium circle-rating--'+rating;
      rating_html = <div className={circleClassName}>{rating}<span className="rating-circle-small">/10</span></div>;
    }
    else{
      let circleClassName = 'circle-rating--equity-blue';
      rating_html = <div className={circleClassName}><span className={this.props.icon_classes}></span></div>;
    }
    return rating_html
  }

  title() {
    return (
      <div>
        { this.props.title }&nbsp;
        { this.props.info_text && 
          <QuestionMarkTooltip content={this.props.info_text} /> }
      </div>
    )
  }

  panes() {
    let dataForActiveTab = this.filteredData()[this.state.active];
    if(!dataForActiveTab) return null;

    let subTabs = dataForActiveTab.data.map(({title, anchor, flagged} = {}, index) => {
      return <a href="javascript:void(0)"
        data-anchor={formatAnchorString(this.props.anchor) + hashSeparatorAnchor() + formatAnchorString(dataForActiveTab.anchor) + hashSeparatorAnchor() + formatAnchorString(anchor)}
        key={index}
        className={'sub-nav-item js-gaClick js-updateLocationHash'}
        onClick={this.handleInnerTabClick.bind(this, index)}
        data-ga-click-category='Profile'
        data-ga-click-action={'Equity Ethnicity Button'}
        data-ga-click-label={title}>
        {title}
        {flagged && <span className="red icon-flag"/>}
      </a>
    });

    let subNav = <SectionSubNavigation active={this.state.activeInnerTab}>
      {subTabs}
    </SectionSubNavigation>

    return dataForActiveTab.data.map(({anchor, type, values, narration} = {}) => {
      let explanation = <div dangerouslySetInnerHTML={{__html: narration}} />
      return <div>
        {subNav}
        <EquityContentPane anchor={anchor} graph={this.createDataComponent(type, values)} text={explanation} />
      </div>
    })
  }

  body() {
    let dataForActiveTab = this.filteredData()[this.state.active];
    if(!dataForActiveTab) return null;

    return (
      <div>
        <div className={'tabs-panel tabs-panel_selected'}>
          <SubSectionToggle
            key={this.state.active}
            active={this.state.activeInnerTab}
            panes={this.panes()}
            parent_anchor={formatAnchorString(dataForActiveTab.anchor)}
            selectTabMatchingAnchor={this.selectInnerTabMatchingAnchor}
          />
        </div>
        <InfoTextAndCircle {...this.props.faq} />
      </div>
    )
  }

  tabs() {
    return (
      <div className="tab-buttons">
        <SectionNavigation active={this.state.active}>
          {this.sectionNavigationTabs()}
        </SectionNavigation>
      </div>
    )
  }

  footer() {
    return (
      <div>
        <InfoBox content={this.props.sources}>{ t('See notes') }</InfoBox>
        <GiveUsFeedback content={this.props.qualaroo_module_link} />
      </div>
    )
  }

  noDataCta() {
    return <NoDataModuleCta moduleName={this.props.title} message={this.props.no_data_summary} />
  }

  render() {
    let analyticsId = this.props.analytics_id;
    if (!this.hasData()) {
      analyticsId += '-empty'; // no data
    }

    return (
      <div id={analyticsId}>
        <BasicDataModuleLayout
          share_content={ this.hasData() && this.props.share_content }
          id={this.props.anchor}
          className=''
          icon={ this.icon() }
          title={ this.title() }
          subtitle={ this.props.subtitle }
          no_data_cta={ !this.hasData() && this.noDataCta() }
          footer={ this.hasData() && this.footer() }
          body={ this.body() }
          tabs={ this.tabs() }
        />
      </div>
    )
  }
};
