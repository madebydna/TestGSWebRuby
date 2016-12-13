import React, { PropTypes } from 'react';

export default class EquityContentPane extends React.Component {

  constructor(props) {
    super(props);
  }
  get_narrative(){
    return this.props.text
  }

  render() {
    return(
      <div className="row">
        <div className="col-xs-12 col-sm-6">{this.props.graph}</div>
        <div className="col-xs-12 col-sm-6">
          <div className="right_content">{this.get_narrative()}</div>
        </div>
      </div>
    )
  }
}

EquityContentPane.propTypes = {
  graph: React.PropTypes.object.isRequired,
  text: React.PropTypes.element.isRequired
};
