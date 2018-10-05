import React from 'react';
import PropTypes from 'prop-types';
import { translateWithDictionary } from 'util/i18n';
import noResultsOwlPng from 'search/no-results-owl.png';
import Ad from 'react_components/ad';

const t = translateWithDictionary({
  en: {
    no_results_suggestions: [
      'To add schools, click on the “♥” button next to schools you want to add to the list on search results or school profile pages.',
      'You can then use this list to compare your favorite schools.'
    ]
  },
  es: {
    no_results_suggestions: [
      'To add schools, click on the “♥” button next to schools you want to add to the list on search results or school profile pages.',
      'You can then use this list to compare your favorite schools.'
    ]
  }
});

const NoMySchoolListResults = ({ resultSummary }) => (
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
          {t('no_results_suggestions').map(suggestion => (
            <li key={suggestion}>{suggestion}</li>
          ))}
        </ul>
      </div>
    </div>
    <Ad sizeName="thin_banner" slot="Search_NoResults_Bottom" />
  </div>
);

NoMySchoolListResults.propTypes = {
  resultSummary: PropTypes.string.isRequired
};

NoMySchoolListResults.defaultProps = {};

export default NoMySchoolListResults;
