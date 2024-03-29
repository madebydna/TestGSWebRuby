import React from 'react';
import PropTypes from 'prop-types';
import { t, capitalize } from 'util/i18n';

export default class ColumnHeader extends React.Component {

  static propTypes = {
    anchor: PropTypes.string,
    leftLabel: PropTypes.string,
    rightLabel: PropTypes.string,
  };

  constructor(props) {
    super(props);
  }

  render() {
    return(
      <div className="row bar-graph-display">
        <div className="test-score-container clearfix">
          <div className="col-sm-5 header-text">{ this.props.leftLabel || capitalize(t('students')) }</div>
          <div className="col-sm-1"></div>
          <div className="col-sm-6 header-text">% { this.props.rightLabel || t('test_scores.at_grade_level')}</div>
        </div>
      </div>
    )
  }
}
