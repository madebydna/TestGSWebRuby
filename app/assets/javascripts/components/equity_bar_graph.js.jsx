class EquityBarGraph extends React.Component {
  constructor(props) {
    super(props);
    this.series = this.series.bind(this);
    this.seriesData = this.seriesData.bind(this);
    this.categories = this.categories.bind(this);
    this.mapColor = this.mapColor.bind(this);
    this.testDataWithEnrollment = this.testDataWithEnrollment.bind(this);
    this.state = {
      subject: 'English Language Arts',
      grade: 'All',
      levelCode: 'e,m,h',
      year: '2015',
    }
  }

  ethnicity() {
    // I dont like that we're reaching out to grab data from outside this
    // component. Would rather have this component's user map 
    // gon.ethnicity to a React prop
    return gon.ethnicity;
  }

  // filter out data that doesn't match ethnicity breakdowns
  testDataMatchingEthnicities() {
    let array = _.map(this.ethnicity(), function(data) {
      let ethnicity = data.breakdown;
      let value = this.props.test_scores[ethnicity];
      if(value) {
        return _.merge(value, {
          ethnicity: ethnicity,
          percentOfStudentBody: data.school_value
        });
      }
    }.bind(this));
    return _.reject(array, obj => obj === undefined);
  }

  // Take filtered test data, and make a new flatter structure
  // that contains state averages, school values, ethnicity, and percent
  // of student body
  testDataWithEnrollment() {
    let mapTestDataToNewObj = function(data) {
      let ethnicity = data.ethnicity;
      let testValues = this.testValues(data);
      return _.merge(testValues, _.pick(data, ['ethnicity','percentOfStudentBody']));
    }.bind(this);

    let data =_.map(this.testDataMatchingEthnicities(), mapTestDataToNewObj);
    if(this.props.test_scores['All']) {
      data.unshift(mapTestDataToNewObj(
        _.merge(
          this.props.test_scores['All'], {
            ethnicity: 'All students'
          }
        )
      ));
    }
    return data;
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
    return _.map(this.testDataWithEnrollment(), function(data) {
      let ethnicity = data.ethnicity;
      let percent = data.percentOfStudentBody;
      let subLabel = '';
      if (ethnicity == 'All students' && this.props.enrollment) {
        subLabel = this.props.enrollment.toLocaleString() + ' students';
      } else if(percent) {
        subLabel = Math.round(percent) + '% of population</span>';
      }
      return ethnicity + '<br/><span style="font-size:smaller">' + subLabel
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
    _.forEach(this.testDataWithEnrollment(), function(value) {
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
    return (<BarGraph graphId="equity-bar-graph" categories={this.categories()} series={this.series()} />);
  }
}

EquityBarGraph.propTypes = {
  test_scores: React.PropTypes.object.isRequired,
  enrollment: React.PropTypes.object.isRequired
}
