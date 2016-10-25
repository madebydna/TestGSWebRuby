class Equity extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      equityContent: this.initializeEquity(),
      test_scores: this.initializeTestScores(),
      enrollment: this.initializeEnrollment(),
      ethnicity: this.initializeEthnicity()
    }
  }

  render() {
    console.log("Love Love Love 1");
    var tabSets = [];
    for (var i = 0; i < this.state.equityContent.length; i++) {
      tabSets.push(<Tabs
          tabs={ this.state.equityContent[i] }
      />)
    }
    return (
        <div>
          <a name="Equity"></a>
          { tabSets }
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

  initializeEquity() {
    // console.log("Love Love Love 2");
    return JSON.parse(JSON.stringify(this.props.equity));
  }
  initializeTestScores() {
    // console.log("Love Love Love 2");
    return JSON.parse(JSON.stringify(this.props.test_scores));
  }
  initializeEnrollment() {
    // console.log("Love Love Love 2");
    return JSON.parse(JSON.stringify(this.props.enrollment));
  }
  initializeEthnicity() {
    // console.log("Love Love Love 2");
    return gon.ethnicity;
  }

};

// Equity.propTypes = {
//   equity: React.PropTypes.arrayOf(React.PropTypes.object({
//     tab_name: React.PropTypes.string,
//     content: React.PropTypes.object
//   }))
// };


//   Equity.propTypes = {
//     data: React.PropTypes.object.isRequired
//   }
//
//
// <div>
//   #equity.test_scores_by_ethnicity.to_json
//
// </div>