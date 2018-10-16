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
  },
  {
    key: 'test_scores_rating',
    label: t('Test scores rating')
  },
  {
    key: 'academic_progress_rating',
    label: t('Academic progress rating')
  },
  {
    key: 'college_readiness_rating',
    label: t('College readiness rating')
  },
  {
    key: 'advanced_courses_rating',
    label: t('Advanced Courses Rating')
  },
  {
    key: 'equity_overview_rating',
    label: t('Equity Overview Rating')
  },
  {
    key: 'test_scores_rating_asian',
    label: t('Test scores rating (Asian)')
  },
  {
    key: 'test_scores_rating_african_american',
    label: t('Test scores rating (African American)')
  },
  {
    key: 'test_scores_rating_filipino',
    label: t('Test scores rating (Filipino)')
  },
  {
    key: 'test_scores_rating_hawaiian',
    label: t('Test scores rating (Hawaiian)')
  },
  {
    key: 'test_scores_rating_hispanic',
    label: t('Test scores rating (Hispanic)')
  },
  {
    key: 'test_scores_rating_hispanic',
    label: t('Test scores rating (Hispanic)')
  },
  {
    key: 'test_scores_rating_native_hawaiian_or_pacific_islander',
    label: t('Test scores rating (Native Hawaiian or Other Pacific Islander)')
  },
  {
    key: 'test_scores_rating_white',
    label: t('Test scores rating (White)')
  },
  {
    key: 'test_scores_rating_two_or_more_races',
    label: t('Test scores rating (Two or more races)')
  },
  {
    key: 'test_scores_rating_pacific_islander',
    label: t('Test scores rating (Pacific Islander)')
  },
  {
    key: 'test_scores_rating_filipino',
    label: t('Test scores rating (Filipino)')
  },
  {
    key: 'test_scores_rating_race_unspecified',
    label: t('Test scores rating (Race Unspecified)')
  },
  {
    key: 'test_scores_rating_other_ethnicity',
    label: t('Test scores rating (Other ethnicity)')
  },
  {
    key: 'test_scores_rating_hawaiian',
    label: t('Test scores rating (Hawaiian)')
  },
  {
    key: 'test_scores_rating_economically_disadvantaged',
    label: t('Test scores rating (Economically disadvantaged)')
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
];

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
