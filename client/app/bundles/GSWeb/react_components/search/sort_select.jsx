import React from 'react';
import Select from '../select';
import SortContext from './sort_context';

const options = [
  {
    key: 'rating',
    label: 'Summary rating'
  },
  {
    key: 'name',
    label: 'School name'
  }
];

const SortSelect = () => (
  <SortContext.Consumer>
    {({ sort = 'rating', onSortChanged }) => (
      <Select
        objects={options}
        labelFunc={d => d.label}
        keyFunc={d => d.key}
        onChange={d => onSortChanged(d.key)}
        defaultLabel={options.find(obj => obj.key === sort).label}
        defaultValue={sort}
      />
    )}
  </SortContext.Consumer>
);

export default SortSelect;
