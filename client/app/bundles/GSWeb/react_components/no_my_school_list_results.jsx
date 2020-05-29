import React from 'react';
import PropTypes from 'prop-types';
import { translateWithDictionary } from 'util/i18n';
import noResultsOwlPng from 'search/no-results-owl.png';

const t = translateWithDictionary({
  en: {
    'Suggestions': 'Suggestions',
    no_school_list: 'Your list is empty',
    no_results_suggestions: [
      'Click on the “♥” button next to the schools from the search results or the school profile page to save your favorite school into this list.',
      'You can then use this list to compare your favorite schools.'
    ]
  },
  es: {
    'Suggestions': 'Sugerencias',
    no_school_list: 'Tu lista está vacía',
    no_results_suggestions: [
      'Haga clic en el botón "♥" al lado de las escuelas en la lista de resultados o en el perfil de la escuela para guardar tu escuela favorita en esta lista.',
      'Luego puedes usar esta lista para comparar tus escuelas favoritas.'
    ]
  }
});

const resultSummary = t('no_school_list')

const NoMySchoolListResults = () => (
  <div className="no-results">
    <div className="body">
      <div>
        <img src={noResultsOwlPng} />
      </div>
      <div>
        <span
          className="heading"
          dangerouslySetInnerHTML={{ __html: resultSummary }}
        />
        <hr />
        <p>{t('Suggestions')}:</p>
        <ul>
          {t('no_results_suggestions').map(suggestion => (
            <li key={suggestion}>{suggestion}</li>
          ))}
        </ul>
      </div>
    </div>
  </div>
);

NoMySchoolListResults.propTypes = {
  resultSummary: PropTypes.string.isRequired
};

NoMySchoolListResults.defaultProps = {};

export default NoMySchoolListResults;
