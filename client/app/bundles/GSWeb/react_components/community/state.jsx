
import React from 'react';
import PropTypes from 'prop-types';
import StateLayout from './state_layout';
import Students from "./students";
import { init as initAdvertising } from 'util/advertising';
import { XS, validSizes as validViewportSizes } from 'util/viewport';
import withViewportSize from 'react_components/with_viewport_size';
import { t } from '../../util/i18n';

class State extends React.Component {
  static defaultProps = {
    schools_data: {},
  };

  static propTypes = {
    viewportSize: PropTypes.oneOf(validViewportSizes).isRequired,
    students: PropTypes.object
  };

  constructor(props) {
    super(props);
    this.pageType = 'state';
  }

  componentDidMount() {
    setTimeout(() => {
      initAdvertising();
    }, 1000);
  }

  hasStudentDemographicData() {
    const { ethnicityData, genderData, subgroupsData } = this.props.students;
    const hasEthnicityData = ethnicityData.filter(o => o.state_value > 0).length > 0
    const hasGenderData = genderData.Male !== undefined && genderData.Female !== undefined;
    let hasSubgroupsData = false;
    Object.entries(subgroupsData).forEach(([key, data]) => {
      if (data.length > 0 && data[0].breakdown === 'All students' && data[0].state_value > 0) { hasSubgroupsData = true }
    });
    return hasEthnicityData || hasGenderData || hasSubgroupsData;
  }

  render() {
    const studentProps = {...this.props.students,...{'pageType': this.pageType}}
    return (
        <StateLayout
            hasStudentDemographicData={this.hasStudentDemographicData()}
            students={<Students {...studentProps} />}
            viewportSize={this.props.viewportSize}
        />
    );
  }
}

const StateWithViewportSize = withViewportSize('size')(State);

export default StateWithViewportSize;
