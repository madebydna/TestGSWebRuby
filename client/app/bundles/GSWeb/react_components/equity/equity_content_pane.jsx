import React, { PropTypes } from 'react';

export default class EquityContentPane extends React.Component {

  static propTypes = {
    graph: React.PropTypes.object.isRequired,
    text: React.PropTypes.element.isRequired
  };

  constructor(props) {
    super(props);
  }
  get_narrative(){
    return this.props.text
  }

  render() {
    let hr_style = ''
    return(
      <div className="row">
        <div className="top-content">{this.get_narrative()}<hr  /></div>

        <div>{this.props.graph}</div>

      </div>
    )
  }
}
