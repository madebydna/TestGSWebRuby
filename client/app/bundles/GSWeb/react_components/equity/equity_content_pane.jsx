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

  // Column header labels (i.e. 'Students', '% Proficient') will be added to every pane unless included in this
  // blacklist, which references anchor props.
  hasColumnHeader() {
    return ['Overview', 'UC/CSU eligibility', 'Graduation rates', 'Advanced_coursework', 'Advanced courses',
      'Percentage AP enrolled grades 9-12', 'Percentage of students suspended out of school', 'College readiness',
      'Percentage of students chronically absent (15+ days)'].indexOf(this.props.anchor) == -1;
  }

  getColumnHeader() {
    if (this.hasColumnHeader()) {
      return <div>{<ColumnHeader anchor={this.props.anchor} />}</div>
    }
  }

  render() {
    let hr_style = ''
    return(
      <div className={'tabs-panel tabs-panel_selected'}>
        <div className="row">
          <div className="top-content">{this.get_narrative()}<hr  /></div>
          {this.getColumnHeader()}
          <div>{this.props.graph}</div>
        </div>
      </div>
    )
  }
}
