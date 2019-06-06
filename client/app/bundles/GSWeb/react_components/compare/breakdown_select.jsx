import React from 'react';
import PropTypes from 'prop-types';
import Select from '../select';
import SortContext from 'react_components/search/sort_context';

const BreakdownSelect = ({ breakdowns }) => {
  return (
    <SortContext.Consumer>
      {({ breakdown, onBreakdownChanged }) => (
        <Select
          objects={breakdowns.sort()}
          labelFunc={d => d}
          keyFunc={d => d}
          onChange={d => onBreakdownChanged(d)}
          defaultLabel={
            (breakdowns.find(obj => obj === breakdown) || breakdowns[0]).label
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
