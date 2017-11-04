import React, { PropTypes } from 'react';
import SchoolProfileComponent from 'react_components/equity/school_profile_component';
import EquityContentPane from 'react_components/equity/equity_content_pane';
import InfoTextAndCircle from 'react_components/info_text_and_circle';

import BarGraphBase from 'react_components/equity/graphs/bar_graph_base';
import BarGraphCustomRanges from 'react_components/equity/graphs/bar_graph_custom_ranges';
import TestScores from 'react_components/equity/graphs/test_scores';
import PersonBar from 'react_components/visualizations/person_bar';
import BasicDataModuleRow from 'react_components/school_profiles/basic_data_module_row';
import PlainNumber from 'react_components/equity/graphs/plain_number';
import RatingWithBar from 'react_components/equity/graphs/rating_with_bar';



export default class CollegeReadiness extends SchoolProfileComponent {

  constructor(props) {
    super(props);
  }

  activePane() {
    let dataForActiveTab = this.filteredData()[this.state.active];

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

    return (
      <div>
        {panes[0]}
        <InfoTextAndCircle {...this.props.faq} />
      </div>
    )
  }

  createDataComponent(values) {
    console.log(values);
    if (values) {
      // This is for titles in the test scores
      if(!(values instanceof Array)){
        return <TestScores test_scores={values}/>;
      }

      if (values.length > 0) {
        let displayType = 'bar';  //default
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
          } else if (value.breakdown == "Average SAT score" || value.breakdown == "Average ACT score") {
            console.log('yeah');
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

