import React, { PropTypes } from 'react';
import { getScript } from '../util/dependency';
import { merge } from 'lodash';

export default class BarGraph extends React.Component {
  static defaultProps = {
    type: 'bar'
  }

  static propTypes = {
    graphId: React.PropTypes.string.isRequired,
    categories: React.PropTypes.array.isRequired,
    series: React.PropTypes.array.isRequired
  }

  constructor(props) {
    super(props);
    this.drawChart = this.drawChart.bind(this);
    this.config = this.config.bind(this);
    this.state = {};
  }

  config() {
    let height = 200;
    if(this.props.type == 'bar') {
      height = Math.max(
        50 + (25 * this.props.series.length * this.props.categories.length),
        150
      );
    }
    return {
      chart: {
        type: this.props.type,
        height: height
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
          },
          labels: {
            style: {
              fontFamily: 'opensans-semibold',
              fontSize: '10px',
              color: '#28292a'
            }
          }
      },
      yAxis: {
          min: 0,
          max: 100,
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
          floating: false,
          borderWidth: 0,
          backgroundColor: ((Highcharts.theme && Highcharts.theme.legendBackgroundColor) || '#FFFFFF'),
          shadow: false
      },
      tooltip: false,
      plotOptions: {
          bar: {
            dataLabels: {
              enabled: true,
              shadow: false,
              style: {
                textShadow: '0px'
              }
            }
          },
          column: {
            dataLabels: {
              enabled: true,
              shadow: false,
              style: {
                textShadow: '0px'
              }
            }
          }
      },
      credits: {
          enabled: false
      }
    }
  }

  drawChart() {
    let callback = function() {
      $(function() {
        let config = this.config();
        config = merge({}, config, { series: this.props.series });
        $('#' + this.props.graphId).highcharts(config);
      }.bind(this));
    }.bind(this);
    if(window.Highcharts) {
      callback();
    } else {
      getScript(gon.dependencies['highcharts']).done(callback);
    }
  }

  componentDidMount() {
    this.drawChart();
  }

  componentDidUpdate() {
    this.drawChart();
  }

  render() {
    return (<div id={this.props.graphId}></div>);
  }
}
