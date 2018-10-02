import React from 'react';
import PropTypes from 'prop-types';
import School from './school';
import SchoolTable from './school_table';

class SchoolTableLayout extends React.Component {
  static propTypes = {
    toggleHighlight: PropTypes.func.isRequired,
    schools: PropTypes.arrayOf(PropTypes.shape(School.propTypes)).isRequired,
    isLoading: PropTypes.bool,
    equityTableRatingsHeader: PropTypes.object,
    subratingHeaderHash: PropTypes.object
  };

  constructor(props) {
    super(props);
    this.state = {
      // table_layout = 'Overview'
    }
  }

  render() {
    return (
        <SchoolTable
            toggleHighlight={this.props.toggleHighlight}
            schools={this.props.schools}
            isLoading={this.props.loadingSchools}
            equityTableRatingsHeader = {this.props.equityTableRatingsHeader}
            subratingHeaderHash = {this.props.subratingHeaderHash}
        />
    );
  }
}

export default SchoolTableLayout;
