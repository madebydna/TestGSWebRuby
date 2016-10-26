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
          icon_classes: ''
        },
        section_content:[{
            section_title: 'Test Scores',
            content: [
              {
                subject: 'English Language Arts',
                component: <LowIncomeBarGraph
                    test_scores={this.incomeLevelTestScoreData('English Language Arts')}
                    type="column"
                    graphId="low-income-bar-graph" />,
                explanation: 'This shows results across different races/ethnicities on an English test given to' +
                ' juniors once a year. Big differences can reflect high numbers of students still learning English. They also may suggest that some students are not getting the support they need to succeed.'
              },
              {
                subject: 'Math',
                component: <EquityBarGraph
                  test_scores={this.incomeLevelTestScoreData('Math')}
                  graphId="test-scores-bar-graph" />,
                explanation: 'This shows results across different races/ethnicities on a Math test given to juniors once a year. Big' +
                ' differences may suggest that some student groups are not getting the support they need to succeed.'
              }
            ]
          },
          {
            section_title: 'Graduation Rates',
            content: [
              {
                subject: 'Math',
                component: 'hello2A',
                explanation: 'Life is a long road'
              },
              {
                subject: 'English',
                component: 'hello2b',
                explanation: 'Life is a long road'
              }
            ]
          }
        ]
      },
      {
        section_info:{
          title: 'Low Income Students',
          icon_classes: ''
        },
        section_content:[
          {
            section_title: 'Test Scores',
            content: [
              {
                subject: 'Math',
                component: 'nothing',
                explanation: 'Life is a long road'
              },
              {
                subject: 'English Language Arts',
                component: 'nothing',
                explanation: 'Life is a long road'
              }
            ]
          },
          {
            section_title: 'Graduation Rates',
            content: [
              {
                subject: 'Math',
                component: 'hello2A',
                explanation: 'Life is a long road'
              },
              {
                subject: 'English',
                component: 'hello2b',
                explanation: 'Life is a long road'
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
  enrollment: React.PropTypes.object
};