class BarGraph extends React.Component {
  constructor(props) {
    super(props);
    this.drawChart = this.drawChart.bind(this);
    this.config = this.config.bind(this);
    this.drawChart();
  }

  config() {
    return {
      chart: {
        type: this.props.type,
        height: 50 + (50 * this.props.categories.length)
      },
      title: {
          text: ''
      },
      subtitle: {
          text: ''
      },
      xAxis: {
          categories: this.props.categories,
          title: {
              text: null
          }
      },
      yAxis: {
          min: 0,
          title: {
              text: '',
              align: 'high'
          },
          labels: {
              overflow: 'justify'
          }
      },
      legend: {
          layout: 'horizontal',
          align: 'center',
          verticalAlign: 'bottom',
          //x: -40,
          //y: 80,
          floating: false,
          borderWidth: 0,
          backgroundColor: ((Highcharts.theme && Highcharts.theme.legendBackgroundColor) || '#FFFFFF'),
          shadow: false
      },
      tooltip: false,
      plotOptions: {
          bar: {
              dataLabels: {
                  enabled: true
              }
          },
      },
      credits: {
          enabled: false
      }
    }
  }

  drawChart() {
    callback = function() {
      $(function() {
        config = this.config();
        config = _.merge(config, { series: this.props.series });
        $('#' + this.props.graphId).highcharts(config);
      }.bind(this));
    }.bind(this);
    if(window.Highcharts) {
      callback();
    } else {
      $.cachedScript("https://code.highcharts.com/highcharts.js").done(callback);
    }
  }

  render() {
    return (<div id={this.props.graphId}></div>);
  }
}

BarGraph.defaultProps = {
  type: 'bar'
}

BarGraph.propTypes = {
  graphId: React.PropTypes.string.isRequired,
  categories: React.PropTypes.array.isRequired,
  series: React.PropTypes.array.isRequired
}
