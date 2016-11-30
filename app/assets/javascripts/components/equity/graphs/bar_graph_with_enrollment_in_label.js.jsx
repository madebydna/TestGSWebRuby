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
        subLabel = Math.round(data.percentOfStudentBody) + '% of students';
      }
      return data.breakdown + ' <span style="font-size:smaller;font-family:opensans-regular;color:#71787e;">(' + subLabel + ')</span>';
    }.bind(this));
  }
}

BarGraphWithEnrollmentInLabel.defaultProps = {
  type: 'bar'
}

BarGraphWithEnrollmentInLabel.propTypes = {
  test_scores: React.PropTypes.arrayOf(React.PropTypes.shape({
    breakdown: React.PropTypes.string.isRequired
  })).isRequired,
  graphId: React.PropTypes.string.isRequired
}
