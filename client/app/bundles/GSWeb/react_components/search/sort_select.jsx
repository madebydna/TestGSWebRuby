import React from 'react';
import PropTypes from 'prop-types';
import Select from '../select';
import SortContext from './sort_context';
import { t } from 'util/i18n';

const defaultOptions = [
  {
    key: 'rating',
    label: t('GreatSchools Rating')
  },
  {
    key: 'name',
    label: t('School name')
  }
];

const distanceOptions = [
  {
    key: 'distance',
    label: t('Distance')
  }
];

const relevanceOption = [
  {
    key: 'relevance',
    label: t('Relevance')
  }
]

const SortSelect = ({ includeDistance, includeRelevance }) => {
  let options = defaultOptions;
  if (includeDistance) {
    options = options.concat(distanceOptions);
  }
  includeRelevance && (options = options.concat(relevanceOption));


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
