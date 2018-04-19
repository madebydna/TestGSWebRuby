import React, { PropTypes } from 'react';
import SchoolProfileComponent from 'react_components/equity/school_profile_component';
import EquityContentPane from 'react_components/equity/equity_content_pane';
import InfoTextAndCircle from 'react_components/info_text_and_circle';

import BarGraphBase from 'react_components/equity/graphs/bar_graph_base';
import BarGraphCustomRanges from 'react_components/equity/graphs/bar_graph_custom_ranges';
import TestScores from 'react_components/equity/graphs/test_scores';
import PersonBar from 'react_components/visualizations/person_bar';
import BasicDataModuleRow from 'react_components/school_profiles/basic_data_module_row';
import RatingWithBar from 'react_components/equity/graphs/rating_with_bar';
import ShareYourFeedbackCollegeReadiness from 'react_components/school_profiles/share_your_feedback_college_readiness';
import BasicDataModuleLayout from 'react_components/school_profiles/basic_data_module_layout';
import SharingModal from 'react_components/school_profiles/sharing_modal';
import Drawer from './drawer';
import { t } from '../util/i18n';
import { showCsaCallout } from 'components/introJs';

export default class CollegeReadiness extends SchoolProfileComponent {

  constructor(props) {
    super(props);
    this.goToQualaroo = this.goToQualaroo.bind(this);
  }

  goToQualaroo(){
    window.open(this.props.feedback.feedback_link, '_blank');
  }

  activePane() {
    let dataForActiveTab = this.filteredData()[this.state.active];
    let title = dataForActiveTab.title;
    let panes = dataForActiveTab.data.map(({anchor, type, values, narration} = {}) => {
      let explanation = <div dangerouslySetInnerHTML={{__html: narration}} />
      return (
        <EquityContentPane
          anchor="College readiness"
          graph={this.createDataComponent(values)}
          text={explanation}
        />
      )
    });
    let paneAndCTA = () => {
      if (title == 'College readiness' || title == 'Preparación universitaria') {
        return <div>
          {panes[0]}
          <InfoTextAndCircle {...this.props.faq} />
        </div>;
      } else if (title == 'College success' || 'Éxito universitario') {
        return <div>
          {panes[0]}
          <ShareYourFeedbackCollegeReadiness buttonText={this.props.feedback.button_text} questionText={this.props.feedback.feedback_cta} buttonClicked={this.goToQualaroo} />
        </div>;
      }
    }

    return (
      paneAndCTA()
    )
  }

  csaBadge() {
    let badge = this.filteredData()[this.state.active].csa_badge;
    return ( badge &&
      <div className="panel clearfix">
        <div className="row">
          <div className="col-xs-12 col-sm-4 csa-image">
            <img src={require('school_profiles/csa-badge-module.png')} />
          </div>
          <div className="col-xs-12 col-sm-8 csa-text">
            <span dangerouslySetInnerHTML={{__html: badge}} />
          </div>
        </div>
      </div>
    )
  }

  componentDidMount() {
    let badge = this.filteredData()[1].csa_badge;
    if (badge && this.filteredData().length > 1) {
      showCsaCallout();
    }
  }

  hasData() {
    return this.filteredData().length > 0
  }

  handleTabClick(index) {
    let tabTitle = this.filteredData()[this.state.active].title;
    this.setState({active: index, activeInnerTab: 0});
    window.analyticsEvent('Profile', 'College Readiness Tabs', tabTitle);
  }

  wrapGraphComponent(graphComponent, value, index) {
    return <BasicDataModuleRow {...value} key={index.toString() + this.state.active}>
      {graphComponent}
    </BasicDataModuleRow>;
  }

  createDataComponent(values) {
    let customScoreRanges = ["Average SAT score", "Calificación media de los SAT", "Average ACT score", "Calificación media de ACT"];
    if (values) {
      if (values.length > 0) {
        // Build array of college readiness data rows
        let dataRows = values.map(function(value, index) {
          if (customScoreRanges.indexOf(value.breakdown) >= 0) {
            return this.wrapGraphComponent(<BarGraphCustomRanges {...value} />, value, index);
          } else {
            switch (value.display_type) {
              case 'plain':
                return <PlainNumber values={values}/>;
              case 'person':
                return this.wrapGraphComponent(<PersonBar {...value}/>, value, index);
              case 'person reversed':
                return this.wrapGraphComponent(<PersonBar {...value} invertedRatings={true}/>, value, index);
              case 'person_gray':
                return this.wrapGraphComponent(<PersonBar {...value} use_gray={true}/>, value, index);
              case 'rating':
                return this.wrapGraphComponent(<RatingWithBar {...value} />, value, index);
              default:
                return this.wrapGraphComponent(<BarGraphBase {...value} />, value, index)
            }
          }
        }.bind(this));
        // Put rows in drawer if more than three
        let visibleDataRows = dataRows.slice(0,3);
        let draweredDataRows = dataRows.slice(3);
        return <div>
                  {visibleDataRows}
                  {draweredDataRows.length > 0 &&
                    <div className="rating-container__more-items">
                      <Drawer
                        content={draweredDataRows}
                        closedLabel={t('Show more')}
                        openLabel={t('Show less')}
                      />
                    </div>}
              </div>
      } else {
        return null;
      }
    }
  }

  render() {
    let analyticsId = this.props.analytics_id;
    if (!this.hasData()) {
      analyticsId += '-empty'; // no data
    }

    return (
      <div id={analyticsId}>
        <BasicDataModuleLayout
          sharing_modal={ this.hasData() && <SharingModal content={this.props.share_content} /> }
          id={this.props.anchor}
          className=''
          icon={ this.icon() }
          title={ this.title() }
          subtitle={ this.props.subtitle }
          no_data_cta={ !this.hasData() && this.noDataCta() }
          footer={ this.hasData() && this.footer() }
          body={ this.hasData() && this.activePane() }
          tabs={ this.hasData() && this.props.showTabs && this.tabsContainer() }
          csa_badge={ this.csaBadge() }
        />
      </div>
    )
  }
};