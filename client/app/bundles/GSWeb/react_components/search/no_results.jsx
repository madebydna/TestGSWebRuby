import React from 'react';
import PropTypes from 'prop-types';
import { t } from 'util/i18n';
import noResultsOwlPng from 'search/no-results-owl.png';
import Ad from 'react_components/ad';

const NoResults = ({ resultSummary }) => (
  <div className="no-results">
    <Ad sizeName="thin_banner" slot="Search_NoResults_Top" />
    <div className="body">
      <img src={noResultsOwlPng} />
      <div>
        <span
          className="heading"
          dangerouslySetInnerHTML={{ __html: resultSummary }}
        />
        <hr />
        <p>Suggestions:</p>
        <ul>
          {t('no_results_suggestions').map(suggestion => <li key={suggestion}>{suggestion}</li>)}
        </ul>
      </div>
    </div>
    <Ad sizeName="thin_banner" slot="Search_NoResults_Bottom" />
  </div>
);

NoResults.propTypes = {
  resultSummary: PropTypes.string.isRequired
};

NoResults.defaultProps = {};

export default NoResults;
