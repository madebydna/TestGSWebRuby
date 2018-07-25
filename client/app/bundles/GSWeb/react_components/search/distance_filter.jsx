import React from 'react';
import PropTypes from 'prop-types';
import { t } from 'util/I18n';

const DistanceFilter = ({ distance, onChange }) => {
  const range = [2, 3, 4, 5, 10, 15, 20, 25, 30, 60];
  const options = [
    {
      key: 1,
      label: `1 ${t('Mile')}`
    }
  ];

  range.forEach(i => {
    options.push({
      key: i,
      label: `${i} ${t('Miles')}`
    });
  });

  const handleChangeEvent = event => onChange(event.target.value);

  return (
    <select
      name="distance"
      onChange={handleChangeEvent}
      defaultValue={distance}
    >
      {options.map(o => (
        <option key={o.key} value={o.key}>
          {o.label}
        </option>
      ))}
    </select>
  );
};

DistanceFilter.propTypes = {
  distance: PropTypes.number,
  onChange: PropTypes.func.isRequired
};

DistanceFilter.defaultProps = {
  distance: 5
};

export default DistanceFilter;
