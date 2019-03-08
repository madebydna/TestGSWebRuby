import React from 'react';
import PropTypes from 'prop-types';
import Remodal from 'react_components/remodal';
import { capitalize, t } from 'util/i18n';

const DistrictBoundariesLegend = ({ legendContainerForCtaId, ...rest }) => {
  const content = (
    <div {...rest}>
      <div id="" style={{ display: 'none' }} />
      <ul className="legend">
        <li>
          <span />{t('District')}
        </li>
        <li>
          <span />{t('Private school')}
        </li>
        <li>
          <span />{t('Public school')}
        </li>
        <li>
          <span />{t('not_rated_school')}
        </li>
        <li>
          <span />{t('school_boundary')}
        </li>
        <li>
          <span />{t('district_boundary')}
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
      <button>{t('view_legend')}</button>
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
