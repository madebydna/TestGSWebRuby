import React from 'react';
import PropTypes from 'prop-types';
import { t, capitalize } from 'util/i18n';
import noResultsOwlPng from 'search/no-results-owl.png';
import Ad from 'react_components/ad';
import CompareContext from './compare_context';

const NoCompareSchoolListResult = () => (
  <CompareContext.Consumer>
    {({ breakdown }) =>
      <div className="no-results">
        <Ad sizeName="thin_banner" slot="Search_NoResults_Top" />
        <div className="body">
          <img src={noResultsOwlPng} />
          <div>
            <hr />
            <p>{t('no_compare_school_title')}</p>
            <ul>
                <li key={breakdown}
                  dangerouslySetInnerHTML={{ 
                    __html: t('no_compare_school_results', { parameters: { breakdown: t(breakdown) }})
                  }}
                />
            </ul>
            <hr />
          </div>
        </div>
        <Ad sizeName="thin_banner" slot="Search_NoResults_Bottom" />
      </div>
    }
  </CompareContext.Consumer>
);

NoCompareSchoolListResult.propTypes = {
};

NoCompareSchoolListResult.defaultProps = {};

export default NoCompareSchoolListResult;
