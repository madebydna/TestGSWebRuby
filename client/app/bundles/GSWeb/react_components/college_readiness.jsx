import React from 'react';
import PropTypes from 'prop-types';
import DataModule from 'react_components/data_module';
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

export default class CollegeReadiness extends DataModule {

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
        </div>;
      }
    }

    return (
      paneAndCTA()
    )
  }

  csaBadge() {
    if (this.filteredData().length > 0) {
      let badge = this.filteredData()[this.state.active].csa_badge;
      return ( badge &&
        <div className="panel clearfix">
          <div className="row csa-profile-module-blurb">
            <div className="col-xs-12 col-sm-3 csa-image">
              <img src={require('school_profiles/csa_generic_badge_lg_icon.png')}/>
            </div>
            <div className="col-xs-12 col-sm-9 csa-text">
              <span dangerouslySetInnerHTML={{__html: badge}}/>
            </div>
          </div>
        </div>
      )
    }
  }

  csaCallout() {
    let eligible = null;
    if(this.filteredData()[1] !== undefined) {
      eligible = this.filteredData()[1].csa_badge;
    }

    return ( eligible &&
      <div className="csa-callout">
        <span className='icon-csa-badge-year'/>
        <span dangerouslySetInnerHTML={{__html: t('csa_callout_html')}}/>
      </div>
    )
  }

  hasData() {
    return this.filteredData().length > 0
  }

  handleTabClick(index) {
    let tabTitle = this.filteredData()[this.state.active].title;
    this.setState({active: index, activeInnerTab: 0, function: () => window.analyticsEvent('Profile', 'College Readiness Tabs', tabTitle)});
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

    let { suppressIfEmpty } = this.props;
    if (!this.hasData() && suppressIfEmpty) {
      return null;
    }

    return (
      <div id={analyticsId}>
        <BasicDataModuleLayout
          sharing_modal={this.hasData() && <SharingModal content={this.props.share_content} />}
          id={this.props.anchor}
          className=''
          icon={this.icon()}
          title={this.title()}
          subtitle={this.props.subtitle}
          no_data_cta={!this.hasData() && this.noDataCta()}
          footer={this.hasData() && this.defaultFooter()}
          body={this.hasData() && this.activePane()}
          csa_badge={this.csaBadge()}
          csaCallout={this.csaCallout()}
        />
      </div>
    )
  }
};