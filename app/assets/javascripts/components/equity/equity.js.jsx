class Equity extends React.Component {
  constructor(props) {
    super(props);
  }

  dataCriteria(subject) {
    return {
      subject: subject,
      grade: 'All',
      level_code: 'e,m,h',
      year: '2015'
    };
  }

  areAllZero(data) {
    return data.filter(obj => obj.school_value !== 0).length == 0;
  }

  section1Tabs() {
    let tabs = [[],[]];

    let data = this.ethnicityTestScoreData('Math');
    if(data && data.length > 0 && !this.areAllZero(data)) {
      tabs[0].push(
          {
            subject: 'Math',
            component: <BarGraphWithEnrollmentInLabel
                test_scores={data}
                graphId="test-scores-math-bar-graph" />,
            explanation: 'This shows results across different races/ethnicities on a Math test given to juniors once a year. Big' +
            ' differences may suggest that some student groups are not getting the support they need to succeed.'
          }
      );
    }

    data = this.ethnicityTestScoreData('English Language Arts');
    if(data && data.length > 0 && !this.areAllZero(data)) {
      tabs[0].push(
        {
          subject: 'English',
          component: <BarGraphWithEnrollmentInLabel
              test_scores={data}
              graphId="test-scores-ela-bar-graph" />,
          explanation: 'This shows results across different races/ethnicities on an English test given to' +
          ' juniors once a year. Big differences can reflect high numbers of students still learning English. They also may suggest that some students are not getting the support they need to succeed.'
        }
      );
    }

    data = this.graduationRateDataByEthnicity();
    if(data && data.length > 0 && !this.areAllZero(data)) {
      tabs[1].push(
        {
          subject: 'Graduation rates',
          component: <EquityBarGraph
              test_scores={data}
              type="bar"
              graphId="graduation-rates-graph" />,
          explanation: 'This shows graduation rates for different races/ethnicities. Big differences may suggest that some students are not getting the support they need to succeed.'
        }
      );
    }

    data = this.entranceRequirementData();
    if(data && data.length > 0 && !this.areAllZero(data)) {
      tabs[1].push(
        {
          subject: 'UC/CSU Eligibility',
          component: <EquityBarGraph
              test_scores={data}
              type="bar"
              graphId="entrance-requirement-graph" />,
          explanation: <div>This shows the percentages of graduates who have taken the A-G required classes needed to be eligible for University of CA and CA state schools. <a href="/gk/articles/dont-miss-these-requirements-to-get-into-college/">Find out more</a> about these requirements.</div>
        }
      )
    }

    return tabs;
  }

  section2Tabs() {
    let tabs = [[],[]];

    let data = this.incomeLevelTestScoreData('Math');
    if(data && data.length > 0 && !this.areAllZero(data)) {
      tabs[0].push(
          {
            subject: 'Math',
            component: <EquityBarGraph
                test_scores={data}
                type="column"
                graphId="low-income-math-bar-graph" />,
            explanation: 'This shows results across different races/ethnicities on a Math test given to juniors once a year. Big' +
            ' differences may suggest that some student groups are not getting the support they need to succeed.'
          }
      );
    }

    data = this.incomeLevelTestScoreData('English Language Arts');
    if(data && data.length > 0 && !this.areAllZero(data)) {
      tabs[0].push(
        {
          subject: 'English',
          component: <EquityBarGraph
              test_scores={data}
              type="column"
              graphId="low-income-ela-bar-graph" />,
          explanation: 'This shows results across different races/ethnicities on an English test given to' +
          ' juniors once a year. Big differences can reflect high numbers of students still learning English. They also may suggest that some students are not getting the support they need to succeed.'
        }
      )
    }


    data = this.graduationRateDataByIncomeLevel();
    if(data && data.length > 0 && !this.areAllZero(data)) {
      tabs[1].push(
        {
          subject: 'Graduation rates',
          component: <EquityBarGraph
              test_scores={data}
              type="bar"
              graphId="graduation-rates-by-income-level-graph" />,
          explanation: 'This shows how graduation rates differ by family income level. Big differences may suggest that some students are not getting the support they need to succeed'
        }
      )
    }
    
    data = this.entranceRequirementByIncomeLevelData();
    if(data && data.length > 0 && !this.areAllZero(data)) {
      tabs[1].push(
        {
          subject: 'UC/CSU Eligibility',
          component: <EquityBarGraph
              test_scores={data}
              type="bar"
              graphId="entrance-requirement-by-income-level-graph" />,
          explanation: <div>This shows the percentages of graduates, by 
            family income level, who have taken the A-G required classes needed 
            to be eligible for University of CA and CA state schools. <a href="/gk/articles/dont-miss-these-requirements-to-get-into-college/">Find out more</a> about these requirements.</div>
        }
      )
    }

    return tabs;
  }

  equityConfiguration(){
    let section1Content = [];
    let section2Content = [];
    let section1Tabs = this.section1Tabs();
    let section2Tabs = this.section2Tabs();
    config = [];

    if(section1Tabs[0].length > 0) {
      section1Content.push(
        {
          section_title: 'Test Scores',
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
          section_title: 'Test Scores',
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
          title: 'Race/Ethnicity',
          rating: ''
        },
        section_content: section1Content
      });
    }

    if(section2Content.length > 0) {
      config.push({
        section_info:{
          title: 'Low Income Students',
          rating: this.lowIncomeRating(),
          icon_classes: 'icon-shield'
        },
        section_content: section2Content
      });
    }

    return config;
  }

  formattedTestScoreData(subject) {
    return GS.testScoresHelpers.filter(
        GS.testScoresHelpers.flatten(this.props.test_scores),
        this.dataCriteria(subject)
    );
  }

  incomeLevelTestScoreData(subject) {
    return GS.testScoresHelpers.incomeLevelTestScoreData(
        this.formattedTestScoreData(subject)
    )
  }

  ethnicityTestScoreData(subject) {
    return this.addEnrollmentIntoTestData(
        GS.testScoresHelpers.testDataMatchingEthnicities(
            this.formattedTestScoreData(subject),
            gon.ethnicity
        )
    )
  }

  graduationRateDataByEthnicity() {
    return GS.testScoresHelpers.testDataMatchingEthnicities(
      this.props.characteristics['4-year high school graduation rate'],
      gon.ethnicity
    );
  }

  graduationRateDataByIncomeLevel() {
    return GS.testScoresHelpers.incomeLevelTestScoreData(
      this.props.characteristics['4-year high school graduation rate'],
      gon.ethnicity
    );
  }
  
  entranceRequirementData() {
    return GS.testScoresHelpers.testDataMatchingEthnicities(
      this.props.characteristics['Percent of students who meet UC/CSU entrance requirements'],
      gon.ethnicity
    );
  }

  entranceRequirementByIncomeLevelData() {
    return GS.testScoresHelpers.incomeLevelTestScoreData(
      this.props.characteristics['Percent of students who meet UC/CSU entrance requirements'],
      gon.ethnicity
    );
  }

  addEnrollmentIntoTestData(testData) {
    // this is an O(n^2) operation
    return _.map(testData,
        function(testData) {
          let newObj = _.merge(
              {}, testData, {
                percentOfStudentBody: (_.find(
                    gon.ethnicity,
                    ethnicityData => ethnicityData.breakdown === testData.breakdown
                ) || {}).school_value
              }
          );
          if (testData.breakdown == 'All students') {
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

Equity.propTypes = {
  test_scores: React.PropTypes.object,
  enrollment: React.PropTypes.object,
  characteristics: React.PropTypes.object,
  rating_low_income: React.PropTypes.object
};
