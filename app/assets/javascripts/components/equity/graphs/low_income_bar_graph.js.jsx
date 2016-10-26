class LowIncomeBarGraph extends React.Component {
  constructor(props) {
    super(props);
    this.series = this.series.bind(this);
    this.seriesData = this.seriesData.bind(this);
    this.categories = this.categories.bind(this);
    this.mapColor = this.mapColor.bind(this);
  }

  testScores() {
    return this._testScores || (
      this._testScores = _.reject(
        this.props.test_scores, 
        function(obj){
          return (obj.score || obj.school_value) === undefined;
        }
      )
    );
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
    return _.map(this.testScores(), data => data.breakdown);
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
    let score = obj.score || obj.school_value;
    return {
      color: this.mapColor(score),
      y: Math.round(score)
    };
  }

  mapDataObjectToStateAverageDataPoint(obj) {
    let score = obj.state_average;
    return {
      color: 'lightgrey',
      y: Math.round(score)
    };
  }

  seriesData() {
    let schoolSeries = _.map(
      this.testScores(),
      this.mapDataObjectToSchoolDataPoint.bind(this)
    );
    let stateAverageSeries = _.map(
      this.testScores(),
      this.mapDataObjectToStateAverageDataPoint.bind(this)
    );

    return {
      schoolSeriesData: schoolSeries,
      stateAverageSeriesData: stateAverageSeries
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
