import React, { PropTypes } from 'react';
import ColumnHeader from '../school_profiles/column_header';

export default class EquityContentPane extends React.Component {

  static propTypes = {
    graph: React.PropTypes.object.isRequired,
    text: React.PropTypes.element.isRequired,
    anchor: React.PropTypes.string
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
      <div className={'tabs-panel tabs-panel_selected'}>
        <div className="row">
          <div className="top-content">{this.get_narrative()}<hr  /></div>
          <div>{<ColumnHeader anchor={this.props.anchor} />}</div>
          <div>{this.props.graph}</div>
        </div>
      </div>
    )
  }
}
