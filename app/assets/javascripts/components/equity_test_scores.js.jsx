class EquityTestScores extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      subject: this.props.subject || 'Math'
    }
  }

  render() {
    graph = <EquityBarGraph test_scores={this.props.test_scores} enrollment={this.props.enrollment} graphId="test-scores-bar-graph" />
    graph = <LowIncomeBarGraph test_scores={this.props.test_scores} enrollment={this.props.enrollment} type="column" graphId="low-income-bar-graph" />
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

EquityTestScores.propTypes = {
  test_scores: React.PropTypes.object.isRequired,
  enrollment: React.PropTypes.object.isRequired,
  subject: React.PropTypes.string
}
