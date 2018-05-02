import React from 'react';
import PropTypes from 'prop-types';
import Remodal from 'react_components/remodal';

const DistrictBoundariesLegend = ({ legendContainerForCtaId, ...rest }) => {
  const content = (
    <div {...rest}>
      <div id="" style={{ display: 'none' }} />
      <ul className="legend">
        <li>
          <span />District
        </li>
        <li>
          <span />Private school
        </li>
        <li>
          <span />Public school
        </li>
        <li>
          <span />Not rated school
        </li>
        <li>
          <span />School boundary
        </li>
        <li>
          <span />District boundary
        </li>
      </ul>
      <div className="attribution">
        School Boundaries © Maponics {new Date().getFullYear()}. Duplication is
        strictly prohibited.
      </div>
    </div>
  );
  return (
    <Remodal content={content}>
      <button>View legend</button>
    </Remodal>
  );
};

DistrictBoundariesLegend.propTypes = {
  legendContainerForCtaId: PropTypes.string
};

DistrictBoundariesLegend.defaultProps = {
  legendContainerForCtaId: ''
};

export default DistrictBoundariesLegend;
