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

  equityConfiguration(){
    return [
      {
        section_info:{
          title: 'Race/Ethnicity',
          rating: '',
          icon_classes: 'icon-shield'
        },
        section_content:[{
            section_title: 'Test Scores',
            content: [
              {
                subject: 'English Language Arts',
                component: <BarGraphWithEnrollmentInLabel
                    test_scores={this.ethnicityTestScoreData('English Language Arts')}
                    graphId="test-scores-ela-bar-graph" />,
                explanation: 'This shows results across different races/ethnicities on an English test given to' +
                ' juniors once a year. Big differences can reflect high numbers of students still learning English. They also may suggest that some students are not getting the support they need to succeed.'
              },
              {
                subject: 'Math',
                component: <BarGraphWithEnrollmentInLabel
                  test_scores={this.ethnicityTestScoreData('Math')}
                  graphId="test-scores-math-bar-graph" />,
                explanation: 'This shows results across different races/ethnicities on a Math test given to juniors once a year. Big' +
                ' differences may suggest that some student groups are not getting the support they need to succeed.'
              }
            ]
          },
          {
            section_title: 'Graduation Rates',
            content: [
              {
                subject: 'Graduation rates',
                component: <EquityBarGraph
                    test_scores={this.graduationRateDataByEthnicity()}
                    type="bar"
                    graphId="graduation-rates-graph" />,
                explanation: 'This shows graduation rates for different races/ethnicities. Big differences may suggest that some students are not getting the support they need to succeed.'
              },
              {
                subject: 'UC/CSU Eligibility',
                component: <EquityBarGraph
                    test_scores={this.entranceRequirementData()}
                    type="bar"
                    graphId="entrance-requirement-graph" />,
                explanation: 'This shows the percentages of graduates who have taken the A-G required classes needed to be eligible for University of CA and CA state schools. Find out more about these requirements.'
              }
            ]
          }
        ]
      },
      {
        section_info:{
          title: 'Low Income Students',
          rating: this.lowIncomeRating(),
          icon_classes: ''
        },
        section_content:[
          {
            section_title: 'Test Scores',
            content: [
              {
                subject: 'English Language Arts',
                component: <EquityBarGraph
                    test_scores={this.incomeLevelTestScoreData('English Language Arts')}
                    type="column"
                    graphId="low-income-ela-bar-graph" />,
                explanation: 'This shows results across different races/ethnicities on an English test given to' +
                ' juniors once a year. Big differences can reflect high numbers of students still learning English. They also may suggest that some students are not getting the support they need to succeed.'
              },
              {
                subject: 'Math',
                component: <EquityBarGraph
                  test_scores={this.incomeLevelTestScoreData('Math')}
                  type="column"
                  graphId="low-income-math-bar-graph" />,
                explanation: 'This shows results across different races/ethnicities on a Math test given to juniors once a year. Big' +
                ' differences may suggest that some student groups are not getting the support they need to succeed.'
              }
            ]
          },
          {
            section_title: 'Graduation Rates',
            content: [
              {
                subject: 'Graduation rates',
                component: <EquityBarGraph
                    test_scores={this.graduationRateDataByIncomeLevel()}
                    type="bar"
                    graphId="graduation-rates-by-income-level-graph" />,
                explanation: 'Donec id elit non mi porta gravida at eget metus. Integer posuere erat a ante venenatis dapibus posuere velit aliquet. Duis mollis, est non commodo luctus, nisi erat porttitor ligula, eget lacinia odio sem nec elit. Nullam id dolor id nibh ultricies vehicula ut id elit.'
              },
              {
                subject: 'UC/CSU Eligibility',
                component: <EquityBarGraph
                    test_scores={this.entranceRequirementByIncomeLevelData()}
                    type="bar"
                    graphId="entrance-requirement-by-income-level-graph" />,
                explanation: 'Donec id elit non mi porta gravida at eget metus. Integer posuere erat a ante venenatis dapibus posuere velit aliquet. Duis mollis, est non commodo luctus, nisi erat porttitor ligula, eget lacinia odio sem nec elit. Nullam id dolor id nibh ultricies vehicula ut id elit.'
              }
            ]
          }
        ]
      }
    ];
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
          if (testData.breakdown == 'All') {
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
