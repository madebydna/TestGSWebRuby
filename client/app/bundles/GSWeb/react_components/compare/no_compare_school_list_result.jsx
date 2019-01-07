import React from 'react';
import PropTypes from 'prop-types';
import { t, capitalize } from 'util/i18n';
import noResultsOwlPng from 'search/no-results-owl.png';
import CompareContext from './compare_context';

const NoCompareSchoolListResult = () => (
  <CompareContext.Consumer>
    {({ breakdown }) => {
      if(breakdown===t("All students")){ breakdown="All"}
      return <div className="no-results">
        <div className="body">
          <img src={noResultsOwlPng} />
          <div>
            <hr />
            <p>{t('no_compare_school_results', { parameters: { breakdown: t(breakdown) }})}</p>
            <ul>
                <li key={breakdown}
                  dangerouslySetInnerHTML={{ 
                    __html: t('try_increasing_distance')
                  }}
                />
            </ul>
            <hr />
          </div>
        </div>
      </div>
    }}
  </CompareContext.Consumer>
);

NoCompareSchoolListResult.propTypes = {
};

NoCompareSchoolListResult.defaultProps = {};

export default NoCompareSchoolListResult;
