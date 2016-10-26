class LowIncomeBarGraph extends React.Component {
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
    return _.map(this.props.test_scores, data => data.breakdown);
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

  mapDataObjectToSchoolDataPoint(obj) {
    let score = obj.score;
    return {
      color: this.mapColor(obj.score),
      y: score
    };
  }

  mapDataObjectToStateAverageDataPoint(obj) {
    let score = obj.state_average;
    return {
      color: this.mapColor(obj.state_average),
      y: score
    };
  }

  seriesData() {
    let schoolSeries = _.map(
      this.props.test_scores,
      this.mapDataObjectToSchoolDataPoint.bind(this)
    );
    let stateAverageSeries = _.map(
      this.props.test_scores,
      this.mapDataObjectToStateAverageDataPoint.bind(this)
    );

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

LowIncomeBarGraph.defaultProps = {
  type: 'bar'
}

LowIncomeBarGraph.propTypes = {
  test_scores: React.PropTypes.array.isRequired,
  graphId: React.PropTypes.string.isRequired
}
