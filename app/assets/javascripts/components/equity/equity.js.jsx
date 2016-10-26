class Equity extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      // subject: this.props.subject || 'Math'
    }
  }

  dataCriteria(subject) {
    return {
      subject: subject, //this.state.subject,
      grade: 'All',
      level_code: 'e,m,h',
      year: '2015'
    };
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

  initContentGraph(){
    return {
      'EquityBarGraph': <EquityBarGraph
          test_scores={this.incomeLevelTestScoreData('Math')}
          graphId="test-scores-bar-graph" />,
      'LowIncomeBarGraph': <LowIncomeBarGraph
          test_scores={this.incomeLevelTestScoreData('English Language Arts')}
          type="column"
          graphId="low-income-bar-graph" />
    }
  }

  initContentText(){
    return {
      'Math': 'This shows results across different races/ethnicities on a Math test given to juniors once a year. Big' +
      ' differences may suggest that some student groups are not getting the support they need to succeed.',
      'English Language Arts': 'This shows results across different races/ethnicities on an English test given to juniors once a' +
      ' year. Big differences can reflect high numbers of students still learning English. They also may suggest that some students are not getting the support they need to succeed.'
    }
  }

  render() {
    // let graph = this.initContentGraph();
    // let explanation = this.initContentText();
    // if(this.state.subject == 'Math') {
    //   text = 'This shows results across different races/ethnicities on a Math test given to juniors once a year. Big differences may suggest that some student groups are not getting the support they need to succeed.'
    // } else if (this.state.subject == 'English Language Arts') {
    //   text = 'This shows results across different races/ethnicities on an English test given to juniors once a year. Big differences can reflect high numbers of students still learning English. They also may suggest that some students are not getting the support they need to succeed.'
    // }

    var equitySections = [];
    for (var i = 0; i < this.props.equity.length; i++) {
      console.log("equity render:"+JSON.stringify(this.props.equity[i]['section_content']));
      equitySections.push(<EquitySection
          equity_config={ this.props.equity[i]['section_content'] }
          graph={this.initContentGraph()}
          explanation={this.initContentText()}
      />)
    }
    return (
        <div>
          <a name="Equity"></a>

          { equitySections }
        </div>
    );
  }

  // render() {
  //   let tabs = [
  //       <Equity
  //   ]
  //
  //   firstTab = <Tabs tabs={} />
  // }

  // getEquityConfig() {
  //   // console.log("Love Love Love 2");
  //   return this.props.equity;
  // }
  // getTestScoresData() {
  //   // console.log("Love Love Love 2");
  //   return this.props.test_scores;
  // }
  // getEnrollmentData() {
  //   // console.log("Love Love Love 2");
  //   return this.props.enrollment;
  // }
  // getEthnicityData() {
  //   // console.log("Love Love Love 2");
  //   return gon.ethnicity;
  // }

};

Equity.propTypes = {
  equity: React.PropTypes.arrayOf(React.PropTypes.object({
    tab_name: React.PropTypes.string,
    content: React.PropTypes.object
  }))
};


//   Equity.propTypes = {
//     data: React.PropTypes.object.isRequired
//   }
//
//
// <div>
//   #equity.test_scores_by_ethnicity.to_json
//
// </div>