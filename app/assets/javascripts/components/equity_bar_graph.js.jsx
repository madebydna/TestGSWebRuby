class EquityBarGraph extends React.Component {
  constructor(props) {
    super(props);
    this.series = this.series.bind(this);
    this.seriesData = this.seriesData.bind(this);
    this.categories = this.categories.bind(this);
    this.mapColor = this.mapColor.bind(this);
    this.state = {
      subject: 'English Language Arts',
      grade: 'All',
      levelCode: 'e,m,h',
      year: '2015'
    }
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

  categories() {
    let values = [];
    _.forOwn(this.props.data, function(value, key) {
      values.push(
        key + '<br/><span style="font-size:smaller">' +
        this.testValues(value).score + ' students tested</span>'
      );
    }.bind(this));
    return values;
  }

  testValues(testDataForBreakdown) {
    return testDataForBreakdown.
      grades[this.state.grade].
      level_code[this.state.levelCode][this.state.subject][this.state.year];
  }

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
    _.forOwn(this.props.data, function(value, key) {
      let testValues = this.testValues(value);
      let stateAverage = this.testValues(value).state_average;
      let schoolScore = this.testValues(value).score;
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
    return (<BarGraph graphId="equity-bar-graph" categories={this.categories()} series={this.series()} />);
  }
}
