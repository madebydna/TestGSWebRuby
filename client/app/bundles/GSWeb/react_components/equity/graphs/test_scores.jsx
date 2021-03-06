import React from 'react';
import TestScoreBarGraphWithGrades from './test_score_bar_graph_with_grades';
import { uniq } from 'lodash';

export default class TestScores extends React.Component {

  constructor(props) {
    super(props);
  }

  showTestScores(){
    var breakdowns = this.combineTestBreakdowns();
    if(this.duplicateBreakdowns(breakdowns)){
      return this.displayWithTestTitles();
    }
    else{
      return breakdowns.map((testData, index) => <TestScoreBarGraphWithGrades {...testData} key={index} />);
    }
  }

  displayContent(key, values){
    return (
      <div key={this.renderKey(key)} >
        <div className="test-title">{key}</div>
        { values.map((testData, index) => <TestScoreBarGraphWithGrades {...testData} key={index} />) }
      </div>
    );
  }

  displayWithTestTitles(){
    var tests = this.props.test_scores;
    var content = [];
    for(var key in tests){
      if (tests.hasOwnProperty(key)){
        content.push(this.displayContent(key, tests[key]));
      }
    }
    return <div>{content}</div>;
  }

  duplicateBreakdowns(breakdowns){
    var initialCount = breakdowns.length;
    let uniqueCount = uniq(breakdowns.map((data) => data['breakdown'])).length;
    return (initialCount > uniqueCount);
  }

  combineTestBreakdowns(){
    var tests = this.props.test_scores;
    var arr = [];
    for(var key in tests){
      if (tests.hasOwnProperty(key)){
        arr = arr.concat(tests[key]);
      }
    }
    return arr;
  }

  renderKey(key){
    return key+Math.random();
  }

  render() {
    return (
      <div>
        { this.showTestScores() }
      </div>
    );
  }
}

