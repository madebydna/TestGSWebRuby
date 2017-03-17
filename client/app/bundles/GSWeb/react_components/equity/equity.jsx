import React, { PropTypes } from 'react';
import testScoresHelpers from '../../util/test_scores_helpers';
import EquityBarGraph from './graphs/equity_bar_graph';
import BarGraphBase from './graphs/bar_graph_base';
import PersonBar from './graphs/person_bar';
import PlainNumber from './graphs/plain_number';
import BarGraphWithEnrollmentInLabel from './graphs/bar_graph_with_enrollment_in_label';
import EquitySection from './equity_section';
import InfoCircle from '../info_circle';

export default class Equity extends React.Component {
  static propTypes = {
    test_scores: React.PropTypes.object,
    enrollment: React.PropTypes.number,
    characteristics: React.PropTypes.object,
    rating_low_income: React.PropTypes.number,
    sources: React.PropTypes.string,
    data: React.PropTypes.object
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

  wordStartsWithAVowel(word){
    let vowels = ["a","e","i","o","u"]
    if(vowels.indexOf(word.toLowerCase().charAt(0)) === -1) {
      return false;
    }
    else{
      return true;
    }
  }

  useAorAn(word){
    if(this.wordStartsWithAVowel(word)) {
      return 'an';
    }
    else{
      return 'a'
    }
  }

  createParametersListSubject(subject){
    return GS.I18n.t('RE Test scores narration', {parameters: {subject: subject}});
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
                explanation: <div>{this.createParametersListSubject(subject)}</div>
              }
          );
        }
      }
    }

    let data = this.graduationRateDataByEthnicity();
    if(data && data.length > 0 && !this.allSchoolValueInvalid(data)) {
      tabs[1].push(
        {
          subject: GS.I18n.t('Graduation rates'),
          component: <EquityBarGraph
              test_scores={data}
              type="bar"
              graphId="graduation-rates-graph" />,
          explanation: <div>{GS.I18n.t('RE Grad rates narration')}</div>
        }
      );
    }

    data = this.entranceRequirementData();
    if(data && data.length > 0 && !this.allSchoolValueInvalid(data)) {
      tabs[1].push(
        {
          subject: GS.I18n.t('UC/CSU eligibility'),
          component: <EquityBarGraph
              test_scores={data}
              type="bar"
              graphId="entrance-requirement-graph" />,
          explanation: <div>{GS.I18n.t('RE UC/CSU eligibility narration')}</div>
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
          subject: GS.I18n.t('Graduation rates'),
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
          subject: GS.I18n.t('UC/CSU eligibility'),
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
      if("narrative" in data[i] && data[i] != ''){
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
          section_title: GS.I18n.t('Test scores'),
          content: section1Tabs[0]
        }
      );
    }
    if(section1Tabs[1].length > 0) {
      section1Content.push(
        {
          section_title: GS.I18n.t('Graduation rates'),
          content: section1Tabs[1]
        }
      );
    }

    if(section2Tabs[0].length > 0) {
      section2Content.push(
        {
          section_title: GS.I18n.t('Test scores'),
          content: section2Tabs[0]
        }
      );
    }
    if(section2Tabs[1].length > 0) {
      section2Content.push(
        {
          section_title: GS.I18n.t('Graduation rates'),
          content: section2Tabs[1]
        }
      );
    }

    if (this.props.data) {
      for (let category in this.props.data) {
        if (this.props.data.hasOwnProperty(category)) {
          let sectionConfig = this.sectionConfig(category, this.props.data[category]);
          if (sectionConfig) {
            section1Content.push(sectionConfig);
          }
        }
      }
    }

    if(section1Content.length > 0) {
      config.push({
        section_info:{
          title: GS.I18n.t('Race ethnicity title'),
          subtitle: <span dangerouslySetInnerHTML={{__html: GS.I18n.t('Race ethnicity subtitle')}} />,
          rating: '',
          info_text: GS.I18n.t('Race ethnicity tooltip'),
          sourceHref: '/gk/ca-high-schools/#Equity-Race-ethnicity',
          icon_classes: GS.I18n.t('Race ethnicity icon')
        },
        section_content: section1Content
      });
    }

    if(section2Content.length > 0) {
      config.push({
        section_info:{
          title: GS.I18n.t('Low income title'),
          subtitle:  <span dangerouslySetInnerHTML={{__html: GS.I18n.t('Low income subtitle')}} />,
          rating: this.lowIncomeRating(),
          icon_classes: GS.I18n.t('Low income icon'),
          info_text: GS.I18n.t('Low income tooltip'),
          sourceHref: '/gk/ca-high-schools/#Equity-Low-Income'
        },
        section_content: section2Content
      });
    }

    return config;
  }

  sectionConfig(name, data) {
    if (data) {
      let content = [];

      for (let subject in data) {
        if (data.hasOwnProperty(subject)) {
          let subjectConfig = this.subjectConfig(subject, data[subject]);
          if (subjectConfig) {
            content.push(subjectConfig);
          }
        }
      }

      if (content.length > 0) {
        return {
          section_title: name,
          content: content
        };
      }
    }
    return null;
  }

  subjectConfig(name, data) {
    if (data && data['values']) {
      let values = data['values'];
      if (values.length > 0) {
        let displayType = data['type'] || 'bar';
        let component = null;
        if (displayType == 'plain') {
          component = <PlainNumber values={values}/>
        } else if (displayType == 'person') {
          component = <PersonBar values={values}/>
        } else {
          component = <BarGraphBase test_scores={values}/>
        }
        return {
          subject: name,
          component: component,
          explanation: <div dangerouslySetInnerHTML={{__html: data['narration']}} />
        };
      }
    }
    return null;
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
          sources={this.props.sources}
      />)
    }
    return (
        <div>
          { equitySections }
        </div>
    );
  }
};

