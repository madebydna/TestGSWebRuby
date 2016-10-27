class BarGraphWithEnrollmentInLabel extends EquityBarGraph {
  constructor(props) {
    super(props);
  }

  // build the labels for each of the bars ("categories in highcharts land")
  categories() {
    return _.map(this.props.test_scores, function(data) {
      let subLabel = '';
      if (data.numberOfStudents) {
        subLabel = data.numberOfStudents.toLocaleString() + ' students';
      } else if(data.percentOfStudentBody) {
        subLabel = Math.round(data.percentOfStudentBody) + '% of population</span>';
      }
      return data.breakdown + '<br/><span style="font-size:smaller">' + subLabel + '</span>';
    }.bind(this));
  }
}

BarGraphWithEnrollmentInLabel.defaultProps = {
  type: 'bar'
}

BarGraphWithEnrollmentInLabel.propTypes = {
  test_scores: React.PropTypes.array.isRequired,
  graphId: React.PropTypes.string.isRequired
}
