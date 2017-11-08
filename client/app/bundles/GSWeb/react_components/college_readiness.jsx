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
          anchor={anchor}
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

  handleTabClick(index) {
    let tabTitle = this.filteredData()[this.state.active].title;
    this.setState({active: index, activeInnerTab: 0});
    window.analyticsEvent('Profile', 'College Readiness Tabs', tabTitle);
  }

  createDataComponent(values) {
    let customScoreRanges = ["Average SAT score", "Calificación media de los SAT", "Average ACT score", "Calificación media de ACT"];
    if (values) {
      // This is for titles in the test scores
      if(!(values instanceof Array)){
        return <TestScores test_scores={values}/>;
      }

      if (values.length > 0) {
        let component = values.map(function(value, index) {
          if (value.display_type == "person") {
            return <BasicDataModuleRow {...value} key={index.toString() + this.state.active}>
              <PersonBar {...value} />
            </BasicDataModuleRow>;
          } else if (value.display_type == "person_reversed"){
            return <BasicDataModuleRow {...value} key={index.toString() + this.state.active}>
              <PersonBar {...value} invertedRatings={true} />
            </BasicDataModuleRow>;
          } else if (value.display_type == "rating") {
            return <BasicDataModuleRow {...value} key={index.toString() + this.state.active}>
              <RatingWithBar {...value} />
            </BasicDataModuleRow>;
          } else if (customScoreRanges.includes(value.breakdown)) {
            return <BasicDataModuleRow {...value} key={index.toString() + this.state.active}>
              <BarGraphCustomRanges {...value} is_percent={false} />
            </BasicDataModuleRow>;
          } else {
            return <BasicDataModuleRow {...value} key={index.toString() + this.state.active}>
              <BarGraphBase {...value} />
            </BasicDataModuleRow>;
          }
        }.bind(this))
        return <div>{component}</div>;
      } else {
        return null;
      }
    }
  }

  hasCSTab() {
    let tabs = this.filteredData().map((pane,idx) => {
      return pane.title
    });
    return tabs.includes('College success');
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
          tabs={ this.hasData() && this.hasCSTab() && this.tabsContainer() }
        />
      </div>
    )
  }
};


