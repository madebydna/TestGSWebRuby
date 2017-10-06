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
import { handleAnchor, addAnchorChangeCallback, removeAnchorChangeCallback, formatAnchorString } from '../../components/anchor_router';


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
    this.state = {
      active: 0
    }
  }

  componentDidMount() {
    this.selectTabMatchingAnchor();
    addAnchorChangeCallback(() => this.selectTabMatchingAnchor());
  }

  componentWillUnmount() {
    removeAnchorChangeCallback(() => this.selectTabMatchingAnchor());
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

  filteredData() {
    return this.props.data.filter(o => o.data && o.data.length > 0)
  }

  hasData() {
    return this.filteredData().length > 0
  }

  propsForSubPanes() {
    let dataForActiveTab = this.filteredData()[this.state.active];
    let props = dataForActiveTab.data.map(({title, anchor, type, values, narration, flagged} = {}) => {
      return {
        title: title,
        anchor: anchor,
        explanation: <div dangerouslySetInnerHTML={{__html: narration}} />,
        flagged: flagged === true,
        component: this.createDataComponent(type, values)
      }; 
    });
    return props;
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

  createSubSectionToggle() {
    let anchorForCurrentlySelectedTab = this.filteredData()[this.state.active].anchor;
    return (
      <div className={'tabs-panel tabs-panel_selected'}>
        <SubSectionToggle
          key={this.state.active}
          panes={this.propsForSubPanes()}
          top_anchor={formatAnchorString(this.props.anchor)}
          parent_anchor={anchorForCurrentlySelectedTab}
        />
      </div>
    )
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
        <span dangerouslySetInnerHTML={{__html: this.props.subtitle}} />
        { !this.hasData() && <NoDataModuleCta moduleName={this.props.title} message={this.props.no_data_summary} /> }
      </div>
    )
  }

  handleTabClick(index) {
    this.setState({active: index})
  }

  render() {
    let analyticsId = this.props.analytics_id;
    if (!this.hasData()) {
      analyticsId += '-empty'; // no data
    }
    let { title, anchor, rating, icon_classes } = this.props;
    let ratingCircle = this.drawRatingCircle(rating, icon_classes);
    let link_name = formatAnchorString(anchor);
    let sectionTitle = this.sectionTitle()

    let content = null;
    if (this.hasData()) {
      return (
        <div id={analyticsId}>
          <div className="rating-container" data-ga-click-label={title}>
            <a className="anchor-mobile-offset" name={link_name}></a>
            <div className="profile-module">
              <div className="module-header">
                <div className="row">
                  <div className="col-xs-12 col-md-10">
                    {ratingCircle}{sectionTitle}
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
                  items={this.filteredData()}
                  active={this.state.active}
                  google_tracking={title}
                  onTabClick={this.handleTabClick.bind(this)}
                />
              </div>
              <div className="panel">
                {this.createSubSectionToggle()}
                <InfoTextAndCircle {...this.props.faq} />
              </div>
              { this.footer(this.props.sources, this.props.qualaroo_module_link) }
            </div>
          </div>
        </div>
      )
    } else {
      return (
        <div id={analyticsId}>
          <div className="rating-container">
            <a className="anchor-mobile-offset" name={link_name}></a>
            <div className="profile-module">
              <div className="module-header">{ratingCircle}{sectionTitle}</div>
            </div>
          </div>
        </div>
      )
    }
  }
};

