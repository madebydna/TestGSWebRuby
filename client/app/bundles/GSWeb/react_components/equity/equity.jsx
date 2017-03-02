import React, { PropTypes } from 'react';
import testScoresHelpers from '../../util/test_scores_helpers';
import EquityBarGraph from './graphs/equity_bar_graph';
import BarGraphBase from './graphs/bar_graph_base';
import BarGraphWithEnrollmentInLabel from './graphs/bar_graph_with_enrollment_in_label';
import EquitySection from './equity_section';
import InfoCircle from '../info_circle';

export default class Equity extends React.Component {
  static propTypes = {
    test_scores: React.PropTypes.object,
    enrollment: React.PropTypes.number,
    characteristics: React.PropTypes.object,
    rating_low_income: React.PropTypes.number
  };

  constructor(props) {
    super(props);
  }

  dataCriteria(subject) {
    return {
      subject: subject,
      grade: 'All',
      level_code: 'e,m,h'
    };
  }

  allSchoolValueInvalid(data) {
    return data.filter(obj => (obj.school_value !== 0 && obj.school_value)).length == 0;
  }

  section1Tabs() {
    let tabs = [[],[]];

    let et = this.props.test_scores['ethnicity'];
    for (var subject in et) {
      if (et.hasOwnProperty(subject)) {
        let subject_data = et[subject];
        if(subject_data && subject_data.length > 0) {
          tabs[0].push(
              {
                subject: subject,
                component: <BarGraphBase
                    test_scores={subject_data} />,
                explanation: <div>This shows results across different races/ethnicities on an {subject} test given to
                           juniors once a year. Big differences can reflect high numbers of students still learning {subject}.
                          They also may suggest that some students are not getting the support they need to succeed.</div>
              }
          );
        }
      }
    }

    let data = this.graduationRateDataByEthnicity();
    if(data && data.length > 0 && !this.allSchoolValueInvalid(data)) {
      tabs[1].push(
        {
          subject: 'Graduation rates',
          component: <EquityBarGraph
              test_scores={data}
              type="bar"
              graphId="graduation-rates-graph" />,
          explanation: <div>This shows graduation rates for different races/ethnicities. Big differences may suggest that some students are not getting the support they need to succeed.</div>
        }
      );
    }

    data = this.entranceRequirementData();
    if(data && data.length > 0 && !this.allSchoolValueInvalid(data)) {
      tabs[1].push(
        {
          subject: 'UC/CSU eligibility',
          component: <EquityBarGraph
              test_scores={data}
              type="bar"
              graphId="entrance-requirement-graph" />,
          explanation: this.narrationContentTestScores(4)
        }
      )
    }

    return tabs;
  }

  narrationContentTestScores(id){
    let narration_str;
    switch(id){
      case 4: { narration_str = 'This shows the percentages of graduates who have taken the A-G required classes needed to ' +
          'be eligible for University of CA and CA state schools. ' +
          '<a href="/gk/articles/dont-miss-these-requirements-to-get-into-college/">Find out more</a> ' +
          'about these requirements.</div>'; break;}
    }

    return <div dangerouslySetInnerHTML={{__html: narration_str}} />;
  }

  section2Tabs() {
    let tabs = [[],[]];

    let li = this.props.test_scores['low_income'];
    for (var subject in li) {
      if (li.hasOwnProperty(subject)) {
        let data = li[subject];
        if(data && data.length > 0) {
          tabs[0].push(
              {
                subject: subject,
                component: <BarGraphBase
                    test_scores={data} />,
                explanation: this.narrationContent(data)
              }
          );
        }
      }
    }

    let data = this.graduationRateDataByIncomeLevel();
    if(data && data.length > 0 && !this.allSchoolValueInvalid(data)){
      tabs[1].push(
        {
          subject: 'Graduation rates',
          component: <EquityBarGraph
              test_scores={data}
              type="bar"
              graphId="graduation-rates-by-income-level-graph" />,
          explanation: this.narrationContent(data)
        }
      )
    }
    
    data = this.entranceRequirementByIncomeLevelData();
    if(data && data.length > 0 && !this.allSchoolValueInvalid(data)) {
      tabs[1].push(
        {
          subject: 'UC/CSU eligibility',
          component: <EquityBarGraph
              test_scores={data}
              type="bar"
              graphId="entrance-requirement-by-income-level-graph" />,
          explanation: this.narrationContent(data)
        }
      )
    }

    return tabs;
  }

  narrationContent(data){
    let len = data.length;
    for(var i=0; i < len; i++){
      if(data[i].breakdown == 'Low-income'){
        return <div dangerouslySetInnerHTML={{__html: data[i]['narrative']}} />;
      }
    }
    for(var i=0; i < len; i++){
      if(data[i].breakdown == 'Not low-income'){
        return <div dangerouslySetInnerHTML={{__html: data[i]['narrative']}} />;
      }
    }
    return <div dangerouslySetInnerHTML={{__html: 'Need default translatable "narration text" from server'}} />;
  }

  equityConfiguration(){
    let section1Content = [];
    let section2Content = [];
    let section1Tabs = this.section1Tabs();
    let section2Tabs = this.section2Tabs();
    let config = [];

    if(section1Tabs[0].length > 0) {
      section1Content.push(
        {
          section_title: 'Test scores',
          content: section1Tabs[0]
        }
      );
    }
    if(section1Tabs[1].length > 0) {
      section1Content.push(
        {
          section_title: 'Graduation rates',
          content: section1Tabs[1]
        }
      );
    }

    if(section2Tabs[0].length > 0) {
      section2Content.push(
        {
          section_title: 'Test scores',
          content: section2Tabs[0]
        }
      );
    }
    if(section2Tabs[1].length > 0) {
      section2Content.push(
        {
          section_title: 'Graduation rates',
          content: section2Tabs[1]
        }
      );
    }

    if(section1Content.length > 0) {
      config.push({
        section_info:{
          title: 'Race/ethnicity',
          subtitle: <span>Achievement gaps between different student groups are common but not insurmountable. Find out <a href="/gk/articles/the-achievement-gap-is-your-school-helping-all-students-succeed/">how to start a conversation</a> at your child's school about the best ways to help all kids succeed.</span>,
          rating: '',
          info_text: 'This section reflects test scores and other important measures for students at this school across different races/ethnicities.',
          sourceHref: '/gk/ca-high-schools/#Equity-Race-ethnicity',
          icon_classes: 'icon-pie'
        },
        section_content: section1Content
      });
    }

    if(section2Content.length > 0) {
      config.push({
        section_info:{
          title: 'Low-income students',
          subtitle: <span>Is your school helping all students succeed? <a href="/gk/articles/the-achievement-gap-is-your-school-helping-all-students-succeed/">Here's what to look for.</a></span>,
          rating: this.lowIncomeRating(),
          icon_classes: 'icon-pie',
          info_text: 'The low-income rating reflects state test scores for students at this school who qualify for free or reduced-price lunch compared to all students in the state.',
          sourceHref: '/gk/ca-high-schools/#Equity-Low-Income'
        },
        section_content: section2Content
      });
    }

    return config;
  }

  formattedTestScoreData(subject) {
    let flattenedTestScoreData = 
        testScoresHelpers.flatten(this.props.test_scores);
    let filterCriteria = this.dataCriteria(subject);
    let maxYear = _.max(_.map(flattenedTestScoreData, obj => obj.year));
    filterCriteria.year = maxYear;
    return testScoresHelpers.filter(
      flattenedTestScoreData, filterCriteria
    );
  }

  incomeLevelTestScoreData(subject) {
    return testScoresHelpers.incomeLevelTestScoreData(
        this.formattedTestScoreData(subject)
    )
  }

  ethnicityTestScoreData(subject) {
    return this.addEnrollmentIntoTestData(
        testScoresHelpers.testDataMatchingEthnicities(
            this.formattedTestScoreData(subject),
            gon.ethnicity
        )
    )
  }

  graduationRateDataByEthnicity() {
    return testScoresHelpers.testDataMatchingEthnicities(
      this.props.characteristics['4-year high school graduation rate'],
      gon.ethnicity
    );
  }

  graduationRateDataByIncomeLevel() {
    return testScoresHelpers.incomeLevelTestScoreData(
      this.props.characteristics['4-year high school graduation rate'],
      gon.ethnicity
    );
  }
  
  entranceRequirementData() {
    return testScoresHelpers.testDataMatchingEthnicities(
      this.props.characteristics['Percent of students who meet UC/CSU entrance requirements'],
      gon.ethnicity
    );
  }

  entranceRequirementByIncomeLevelData() {
    return testScoresHelpers.incomeLevelTestScoreData(
      this.props.characteristics['Percent of students who meet UC/CSU entrance requirements'],
      gon.ethnicity
    );
  }

  addEnrollmentIntoTestData(testData) {
    // this is an O(n^2) operation
    return _.map(testData,
      function(testData) {
        let matchingEthnicity = _.find(
          gon.ethnicity,
          ethnicityData => ethnicityData.original_breakdown === testData.breakdown
        ) || {};
        let newObj = _.merge(
          {}, testData, {
            percentOfStudentBody: matchingEthnicity['school_value'],
            breakdown: matchingEthnicity['breakdown'] || testData.breakdown
          }
        );
        if (testData.breakdown == 'All') {
          newObj.breakdown = 'All students';
          newObj.numberOfStudents = this.props.enrollment;
        }
        return newObj;
      }.bind(this)
    );
  }

  lowIncomeRating(){
    return this.props.rating_low_income
  }

  ethnicities() {
    return _.map(gon.ethnicity, obj => obj.breakdown);
  }

  render() {
    let equityConfig = this.equityConfiguration();

    var equitySections = [];
    for (var i = 0; i < equityConfig.length; i++) {
      equitySections.push(<EquitySection
          key={i}
          equity_config={ equityConfig[i]}

      />)
    }
    return (
        <div>
          { equitySections }
        </div>
    );
  }
};

