import React, { PropTypes } from 'react';
import { t, capitalize } from '../../util/i18n';

export default class EquityContentPane extends React.Component {

  static propTypes = {
    graph: React.PropTypes.object.isRequired,
    text: React.PropTypes.element.isRequired,
    anchor: React.PropTypes.string,
    showGraphColumnHeader: React.PropTypes.bool
  };

  constructor(props) {
    super(props);
  }
  get_narrative(){
    return this.props.text
  }

  getGraphColumnHeader(){
    if (this.props.showGraphColumnHeader) {
      return <div className="row bar-graph-display">
        <div className="test-score-container clearfix">
          <div className="col-sm-5 header-text">{ capitalize(t('students')) }</div>
          <div className="col-sm-1"></div>
          <div className="col-sm-6 header-text">% {t('test_scores.proficient')}</div>
        </div>
      </div>
    }
  }

  render() {
    let hr_style = ''
    return(
      <div className={'tabs-panel tabs-panel_selected'}>
        <div className="row">
          <div className="top-content">{this.get_narrative()}<hr  /></div>
          <div>{this.getGraphColumnHeader()}</div>
          <div>{this.props.graph}</div>
        </div>
      </div>
    )
  }
}
