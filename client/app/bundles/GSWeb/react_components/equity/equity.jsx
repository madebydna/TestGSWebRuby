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
    courses: React.PropTypes.object,
    discipline: React.PropTypes.object,
    disabilities: React.PropTypes.object
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

    // let data = this.graduationRateDataByEthnicity();
    // if(data && data.length > 0 && !this.allSchoolValueInvalid(data)) {
    //   tabs[1].push(
    //     {
    //       subject: GS.I18n.t('Graduation rates'),
    //       component: <EquityBarGraph
    //           test_scores={data}
    //           type="bar"
    //           graphId="graduation-rates-graph" />,
    //       explanation: <div dangerouslySetInnerHTML={{__html: GS.I18n.t('RE Grad rates narration')}}/>
    //     }
    //   );
    // }

    let data = this.entranceRequirementData();
    if(data && data.length > 0 && !this.allSchoolValueInvalid(data)) {
      tabs[1].push(
        {
          subject: GS.I18n.t('UC/CSU eligibility'),
          component: <EquityBarGraph
              test_scores={data}
              type="bar"
              graphId="entrance-requirement-graph" />,
          explanation: <div dangerouslySetInnerHTML={{__html: GS.I18n.t('RE UC/CSU eligibility narration')}}/>
        }
      )
    }

    return tabs;
  }

  translateNarrationWithSubject(subject){
    return GS.I18n.t('SD Test scores narration', {parameters: {subject: subject}});
  }

  section3Tabs() {
    let tabs = [[],[]];

    let li = this.props.test_scores['disabilities'];
    for (var subject in li) {
      if (li.hasOwnProperty(subject)) {
        let data = li[subject];
        if(data && data.length > 0) {
          tabs[0].push(
              {
                subject: subject,
                component: <BarGraphBase
                    test_scores={data} />,
                explanation: <div dangerouslySetInnerHTML={{__html: this.translateNarrationWithSubject(subject)}}/>
              }
          );
        }
      }
    }
    return tabs;
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

  followSchoolForDataUpdates = function (event) {
      var state = GS.stateAbbreviationFromUrl();
      var schoolId = GS.schoolIdFromUrl();
      return GS.sendUpdates.signupAndFollowSchool(state, schoolId);
  };

  equityConfiguration(){
    let section1Content = [];
    let section2Content = [];
    let section3Content = [];
    let section1Tabs = this.section1Tabs();
    let section2Tabs = this.section2Tabs();
    let section3Tabs = this.section3Tabs();
    let config = [];

    // if(section1Tabs[1].length > 0) {
    //   section1Content.push(
    //     {
    //       section_title: GS.I18n.t('Graduation rates'),
    //       content: section1Tabs[1]
    //     }
    //   );
    // }

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

    if(section3Tabs[0].length > 0) {
      section3Content.push(
          {
            section_title: GS.I18n.t('Test scores'),
            content: section3Tabs[0]
          }
      );
    }

    if (this.props.courses) {
      for (let category in this.props.courses) {
        if (this.props.courses.hasOwnProperty(category)) {
          let sectionConfig = this.sectionConfig(category, this.props.courses[category]);
          if (sectionConfig) {
            section1Content.push(sectionConfig);
          }
        }
      }
    }

    if (this.props.discipline) {
      for (let category in this.props.discipline) {
        if (this.props.discipline.hasOwnProperty(category)) {
          let sectionConfig = this.sectionConfig(category, this.props.discipline[category]);
          if (sectionConfig) {
            section1Content.push(sectionConfig);
          }
        }
      }
    }

    if (this.props.disabilities) {
      for (let category in this.props.disabilities) {
        if (this.props.disabilities.hasOwnProperty(category)) {
          let sectionConfig = this.sectionConfig(category, this.props.disabilities[category]);
          if (sectionConfig) {
            section3Content.push(sectionConfig);
          }
        }
      }
    }

    if(section1Content.length > 0) {
      config.push({
        section_info:{
          title: 'Race ethnicity',
          subtitle: <span dangerouslySetInnerHTML={{__html: GS.I18n.t('Race ethnicity subtitle')}} />,
          rating: '',
          info_text: GS.I18n.t('Race ethnicity tooltip'),
          sourceHref: '/gk/ca-high-schools/#Equity-Race-ethnicity',
          icon_classes: GS.I18n.t('Race ethnicity icon')
        },
        section_content: section1Content
      });
    }
    else {
      config.push({
        section_info:{
          title: 'Race ethnicity',
          subtitle: <span dangerouslySetInnerHTML={{__html: GS.I18n.t('Race ethnicity subtitle')}} />,
          message: <div className="ptm">
                    <span dangerouslySetInnerHTML={{__html: GS.I18n.t('no_data_message')}} />
                    <a href="javascript:void(0)"
                       className="js-followThisSchool js-gaClick"
                       onClick={this.followSchoolForDataUpdates} dangerouslySetInnerHTML={{__html: GS.I18n.t('notify_me')}}
                       data-ga-click-category='Profile'
                       data-ga-click-action='Notify from empty data module'
                       data-ga-click-label='Race ethnicity' />
                   </div>,
          rating: '',
          info_text: GS.I18n.t('Race ethnicity tooltip'),
          sourceHref: '/gk/ca-high-schools/#Equity-Race-ethnicity',
          icon_classes: GS.I18n.t('Race ethnicity icon')
        }
      })
    }

    if(section2Content.length > 0) {
      config.push({
        section_info:{
          title: 'Low-income students',
          subtitle:  <span dangerouslySetInnerHTML={{__html: GS.I18n.t('Low income subtitle')}} />,
          rating: this.lowIncomeRating(),
          icon_classes: GS.I18n.t('Low income icon'),
          info_text: GS.I18n.t('Low income tooltip'),
          sourceHref: '/gk/ca-high-schools/#Equity-Low-Income'
        },
        section_content: section2Content
      });
    }
    else {
      config.push({
        section_info:{
          title: 'Low-income students',
          subtitle:  <span dangerouslySetInnerHTML={{__html: GS.I18n.t('Low income subtitle')}} />,
          message: <div className="ptm">
                    <span dangerouslySetInnerHTML={{__html: GS.I18n.t('no_data_message')}} />
                    <a href="javascript:void(0)"
                       className="js-followThisSchool js-gaClick"
                       onClick={this.followSchoolForDataUpdates} dangerouslySetInnerHTML={{__html: GS.I18n.t('notify_me')}}
                       data-ga-click-category='Profile'
                       data-ga-click-action='Notify from empty data module'
                       data-ga-click-label='Low-income students' />
                   </div>,
          rating: '',
          icon_classes: GS.I18n.t('Low income icon'),
          info_text: GS.I18n.t('Low income tooltip'),
          sourceHref: '/gk/ca-high-schools/#Equity-Low-Income'
        }
      })
    }

    if(section3Content.length > 0) {
      config.push({
        section_info:{
          title: 'Students with Disabilities',
          subtitle: '',
          rating: '',
          icon_classes: GS.I18n.t('Student with disabilities icon'),
          info_text: GS.I18n.t('Student with disabilities tooltip'),
          sourceHref: '/gk/ca-high-schools/#Students with Disabilities'
        },
        section_content: section3Content
      });
    }
    else {
      config.push({
        section_info:{
          title: 'Students with Disabilities',
          subtitle: '',
          message: <div className="ptm">
                    <span dangerouslySetInnerHTML={{__html: GS.I18n.t('no_data_message')}} />
                    <a href="javascript:void(0)"
                       className="js-followThisSchool js-gaClick"
                       onClick={this.followSchoolForDataUpdates} dangerouslySetInnerHTML={{__html: GS.I18n.t('notify_me')}}
                       data-ga-click-category='Profile'
                       data-ga-click-action='Notify from empty data module'
                       data-ga-click-label='Students with Disabilities' />
                   </div>,
          rating: '',
          icon_classes: GS.I18n.t('Race ethnicity icon'),
          info_text: GS.I18n.t('Student with disabilities tooltip'),
          sourceHref: '/gk/ca-high-schools/#Students with Disabilities'
        }
      })
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
          component = <PersonBar values={values} />
        } else if (displayType == 'person_reversed') {
          component = <PersonBar values={values} invertedRatings={true} />
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
