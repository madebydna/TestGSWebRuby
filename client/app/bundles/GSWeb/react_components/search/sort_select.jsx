import React from 'react';
import PropTypes from 'prop-types';
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
]

const SortSelect = ({}) => {
  return (
    <SortContext.Consumer>
      {({sort='rating', onSortChanged}) => {
        return <Select objects={options}
          labelFunc={d => d.label}
          keyFunc={d => d.key}
          onChange={d => onSortChanged(d.key)}
          defaultLabel={options.find(obj => obj.key == sort).label}
          defaultValue={sort}
        />
      }}
    </SortContext.Consumer>
  )
};

export default SortSelect;

