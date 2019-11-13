import React from 'react';
import PropTypes from 'prop-types';
import { XS, SM, LG, MD, validSizes } from 'util/viewport';
import OpenableCloseable from 'react_components/openable_closeable';
import Button from 'react_components/button';
import Ad from 'react_components/ad';
import { t, capitalize } from 'util/i18n';
import { keepInViewport } from 'util/sticky';

class StateLayout extends React.Component {
  static propTypes = {
    viewportSize: PropTypes.oneOf(validSizes).isRequired
  };

  constructor(props) {
    super(props);
    this.ad = React.createRef();
    this.state = {}
  }

  componentDidMount() {
  }

  renderStudentsModule() {
    return (this.props.hasStudentDemographicData &&
      <div id="students" className="module-section">
        {this.props.students}
      </div>
    )
  }
  
  render() {
    return (
      <React.Fragment>
        {this.renderStudentsModule()}
      </React.Fragment>
    );
  }
}

export default StateLayout;
