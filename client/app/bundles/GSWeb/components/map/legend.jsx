import React from 'react';

export default class Legend extends React.Component {
  constructor(props) {
    super(props);
    this.state = {open: false};
  }

  toggleLegend() {
    this.setState({open: !this.state.open});
  }

  getLegendClass() {
    if (this.state.open == true) {
      return ' legend-open'
    } else {
      return ''
    }
  }

  renderLegendContent(){
    if (this.state.open == true) {
      return <div className={'legend-content'}>{this.props.content}</div>
    } else {
      // do nothing
    }
  }

  render() {
    return <div className={'map-legend' + this.getLegendClass()} onClick={() => this.toggleLegend()}>
      View legend
      <span className="icon-chevron-right"></span>
      {this.renderLegendContent()}
    </div>
  }
}