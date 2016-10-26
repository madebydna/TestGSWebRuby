class EquityBarGraph extends React.Component {
  constructor(props) {
    super(props);
    this.series = this.series.bind(this);
    this.seriesData = this.seriesData.bind(this);
    this.categories = this.categories.bind(this);
    this.mapColor = this.mapColor.bind(this);
  }

  series() {
    let seriesData = this.seriesData();

    return [{
      name: 'School value',
      showInLegend: false,
      data: seriesData.schoolSeriesData,
      dataLabels: { format: '{y}%' }
    }, {
      name: 'State average',
      color: 'lightgrey',
      data: seriesData.stateAverageSeriesData,
      dataLabels: { format: '{y}%' }
    }];
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
      return data.breakdown + '<br/><span style="font-size:smaller">' + subLabel
    }.bind(this));
  }

  // helper method to index into hierarchical test score data
  // and grab test values for a given grade, level, subject, and year
  testValues(testDataForBreakdown) {
    return testDataForBreakdown.
      grades[this.state.grade].
      level_code[this.state.levelCode][this.state.subject][this.state.year];
  }

  // helper method to map a score to a color for bars
  mapColor(value) {
    return {
      1: '#F26B16',
      2: '#E78818',
      3: '#DCA21A',
      4: '#D2B81B',
      5: '#BDC01E',
      6: '#A3BE1F',
      7: '#86B320',
      8: '#6BA822',
      9: '#559F24',
      10: '#439326'
    }[Math.ceil(value/10)]
  }

  seriesData() {
    let schoolSeries = [];
    let stateAverageSeries = [];
    _.forEach(this.props.test_scores, function(value) {
      if(!value) {
        return;
      }
      let stateAverage = value.state_average;
      let schoolScore = value.score;
      schoolSeries.push({
        color: this.mapColor(schoolScore),
        y: schoolScore
      });
      stateAverageSeries.push({
        color: 'lightgrey',
        y: stateAverage
      });
    }.bind(this));

    return {
      stateAverageSeriesData: stateAverageSeries,
      schoolSeriesData: schoolSeries
    };
  }

  render() {
    return (<BarGraph graphId={this.props.graphId}
      categories={this.categories()}
      series={this.series()}
      type={this.props.type} />);
  }
}

EquityBarGraph.defaultProps = {
  type: 'bar'
}

EquityBarGraph.propTypes = {
  test_scores: React.PropTypes.array.isRequired,
  graphId: React.PropTypes.string.isRequired
}
