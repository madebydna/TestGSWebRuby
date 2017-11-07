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



export default class CollegeReadiness extends SchoolProfileComponent {

  constructor(props) {
    super(props);
  }

  goToQualaroo(){
    window.open('https://s.qualaroo.com/45194/cb0e676f-324a-4a74-bc02-72ddf1a2ddd6', '_blank');
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
            return <BasicDataModuleRow {...value} key={index}>
              <PersonBar {...value} />
            </BasicDataModuleRow>;
          } else if (value.display_type == "person_reversed"){
            return <BasicDataModuleRow {...value} key={index}>
              <PersonBar {...value} invertedRatings={true} />
            </BasicDataModuleRow>;
          } else if (value.display_type == "rating") {
            return <BasicDataModuleRow {...value} key={index}>
              <RatingWithBar {...value} />
            </BasicDataModuleRow>;
          } else if (customScoreRanges.includes(value.breakdown)) {
            return <BasicDataModuleRow {...value} key={index}>
              <BarGraphCustomRanges {...value} is_percent={false} />
            </BasicDataModuleRow>;
          } else {
            return <BasicDataModuleRow {...value} key={index}>
              <BarGraphBase {...value} />
            </BasicDataModuleRow>;
          }
        })
        return <div>{component}</div>;
      } else {
        return null;
      }
    }
  }
};


