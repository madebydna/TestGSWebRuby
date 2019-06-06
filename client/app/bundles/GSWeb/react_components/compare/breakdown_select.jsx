import React from 'react';
import PropTypes from 'prop-types';
import Select from '../select';
import SortContext from 'react_components/search/sort_context';
import { t } from '../../util/i18n';

const BreakdownSelect = ({ breakdowns }) => {
  const options = [];
  breakdowns.sort().forEach((bd) => {
    options.push({
      key: bd,
      label: t(`breakdowns.${bd}`)
    });
  });
  return (
    <SortContext.Consumer>
      {({ breakdown, onBreakdownChanged }) => (
        <Select
          objects={options}
          labelFunc={d => d.label}
          keyFunc={d => d.key}
          onChange={d => onBreakdownChanged(d.key)}
          defaultLabel={
            (options.find(obj => obj.key === breakdown) || options[0]).label
          }
          defaultValue={breakdown}
        />
      )}
    </SortContext.Consumer>
  );
};

export default BreakdownSelect;

BreakdownSelect.propTypes = {
  breakdowns: PropTypes.array
};

BreakdownSelect.defaultProps = {
  breakdowns: []
};
