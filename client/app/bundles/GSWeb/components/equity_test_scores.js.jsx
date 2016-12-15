class EquityTestScores extends React.Component {

  static propTypes = {
    test_scores: React.PropTypes.object.isRequired,
    enrollment: React.PropTypes.object.isRequired,
    subject: React.PropTypes.string
  }

  constructor(props) {
    super(props);
    this.state = {
      subject: this.props.subject || 'Math'
    }
  }

  dataCriteria() {
    return {
      subject: this.state.subject,
      grade: 'All',
      level_code: 'e,m,h',
      year: '2015' 
    };
  }

  formattedTestScoreData() {
    return GS.testScoresHelpers.filter(
      GS.testScoresHelpers.flatten(this.props.test_scores),
      this.dataCriteria()
    );
  }

  incomeLevelTestScoreData() {
    return GS.testScoresHelpers.incomeLevelTestScoreData(
      this.formattedTestScoreData()
    )
  }

  ethnicityTestScoreData() {
    return this.addEnrollmentIntoTestData(
      GS.testScoresHelpers.testDataMatchingEthnicities(
        this.formattedTestScoreData(),
        gon.ethnicity
      )
    )
  }

  graduationRateData() {
    return GS.testScoresHelpers.testDataMatchingEthnicities(
      this.props.graduation_rate_data,
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

  ethnicities() {
    return _.map(gon.ethnicity, obj => obj.breakdown);
  }

  render() {
    graph = <EquityBarGraph
      test_scores={this.ethnicityTestScoreData()}
      graphId="test-scores-bar-graph" />

    graph2 = <LowIncomeBarGraph
      test_scores={this.incomeLevelTestScoreData()}
      type="column"
      graphId="low-income-bar-graph" />

    graph3 = <LowIncomeBarGraph
      test_scores={this.graduationRateData()}
      type="bar"
      graphId="graduation-rate-bar-graph" />

    let text = undefined;
    if(this.state.subject == 'Math') {
      text = 'This shows results across different races/ethnicities on a Math test given to juniors once a year. Big differences may suggest that some student groups are not getting the support they need to succeed.'
    } else if (this.state.subject == 'English Language Arts') {
      text = 'This shows results across different races/ethnicities on an English test given to juniors once a year. Big differences can reflect high numbers of students still learning English. They also may suggest that some students are not getting the support they need to succeed.'
    }
    return (
      <EquityContentPane graph={graph} text={text} />
    )
  }
}
