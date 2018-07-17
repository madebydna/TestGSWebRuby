import React from 'react';
import PropTypes from 'prop-types';
import Select from '../select';
import SortContext from './sort_context';

const defaultOptions = [
  {
    key: 'rating',
    label: 'Summary rating'
  },
  {
    key: 'name',
    label: 'School name'
  }
];

const distanceOptions = [
  {
    key: 'distance',
    label: 'Distance'
  }
];

const SortSelect = ({ includeDistance }) => {
  let options = defaultOptions;
  if (includeDistance) {
    options = options.concat(distanceOptions);
  }

  return (
    <SortContext.Consumer>
      {({ sort, onSortChanged }) => (
        <Select
          objects={options}
          labelFunc={d => d.label}
          keyFunc={d => d.key}
          onChange={d => onSortChanged(d.key)}
          defaultLabel={
            (options.find(obj => obj.key === sort) || options[0]).label
          }
          defaultValue={sort}
        />
      )}
    </SortContext.Consumer>
  );
};

export default SortSelect;

SortSelect.propTypes = {
  includeDistance: PropTypes.bool
};

SortSelect.defaultProps = {
  includeDistance: false
};
