import React from 'react';
import PropTypes from 'prop-types';
import { merge } from 'lodash';
import Select from '../select';
import SortContext from './sort_context';
import { translateWithDictionary } from 'util/i18n';

const dictionary = {
  en: {
    rating: 'GreatSchools Rating',
    name: 'School name',
    testscores: 'Test scores',
    relevance: 'Relevance',
    distance: 'Distance',
  },
  es: {
    rating: 'Calificación de GreatSchools',
    name: 'Nombre de escuela',
    testscores: 'Resultados de exámenes',
    relevance: 'Pertinencia',
    distance: 'Distancia'
  }
};

const ratingDictionary = {
  en: {},
  es: {
    'Test Scores Rating': 'Resultados de Exámenes',
    'Student Progress Rating': 'Progreso del Estudiante',
    'Academic Progress Rating': 'Progreso Académico',
    'College Readiness Rating': 'Preparación Universitaria',
    'Equity Overview Rating': 'Resumen de Equidad'
  }
};

const tRatingLabel = translateWithDictionary(ratingDictionary);

const ratingFieldDictionary = Object.keys(ratingDictionary.es).reduce(
  (dict, ratingLabel) => {
    const spaceRegexp = new RegExp(' ', 'g');
    const ratingField = ratingLabel.toLowerCase().replace(spaceRegexp, '_');
    dict.en[ratingField] = tRatingLabel(ratingLabel, {
      locale: 'en'
    });
    dict.es[ratingField] = tRatingLabel(ratingLabel, {
      locale: 'es'
    });
    return dict;
  },
  {
    en: {},
    es: {}
  }
);

const breakdownDictionary = {
  en: {
    'Black': 'African American',
    All: 'All students',
    Multiracial: 'Two or more races',
    'Native American': 'American Indian/Alaska Native',
    'Hawaiian Native/Pacific Islander': 'Pacific Islander',
    'Native Hawaiian or Other Pacific Islander': 'Pacific Islander',
    'Economically disadvantaged': 'Low-income',
    'Low Income': 'Low-income'
  },
  es: {
    'African American': 'Afroamericanos',
    Black: 'Afroamericanos',
    White: 'Blancos',
    Asian: 'Asiático',
    Hispanic: 'Hispanos/Latinos',
    'Asian or Pacific Islander': 'Asiático o Isleños del Pacífico',
    All: 'Todos',
    Multiracial: 'Dos o más razas',
    'Two or more races': 'Dos o más razas',
    'American Indian/Alaska Native':
      'Los indios americanos / nativos de Alaska',
    'Native American': 'Los indios americanos / nativos de Alaska',
    'Pacific Islander': 'Islas del Pacífico',
    'Hawaiian Native/Pacific Islander': 'Islas del Pacífico',
    'Native Hawaiian or Other Pacific Islander': 'Islas del Pacífico',
    'Economically disadvantaged': 'De bajos ingresos',
    'Low Income': 'De bajos ingresos'
  }
};

const tBreakdown = translateWithDictionary(breakdownDictionary);

// This uses the existing rating field / breakdown name dictionaries to build
// a new dictionary that translates strings of the format:
// rating_field_name_breakdown_name to Rating Name (Breakdown Name)
const ratingBreakdownFieldDictionary = Object.keys(ratingDictionary.es).reduce(
  (dict, ratingLabel) => {
    const spaceRegexp = new RegExp(' ', 'g');
    Object.keys(breakdownDictionary.es).forEach(breakdown => {
      // Test Scores Rating => test_scores_rating
      const ratingField = ratingLabel.toLowerCase().replace(spaceRegexp, '_');
      const newKey = `${ratingField}_${breakdown
        .toLowerCase()
        .replace(spaceRegexp, '_')}`;
      dict.en[newKey] = `${tRatingLabel(ratingLabel, {
        locale: 'en'
      })} (${tBreakdown(breakdown, { locale: 'en' })})`;
      dict.es[newKey] = `${tRatingLabel(ratingLabel, {
        locale: 'es'
      })} (${tBreakdown(breakdown, { locale: 'es' })})`;
    });

    dict.en["Economically_disadvantaged"] = `${tRatingLabel("Test Scores Rating", {
      locale: 'en'
    })} (${tBreakdown("Economically disadvantaged", { locale: 'en' })})`;
    dict.es["Economically_disadvantaged"] = `${tRatingLabel("Test Scores Rating", {
      locale: 'es'
    })} (${tBreakdown("Economically disadvantaged", { locale: 'es' })})`;

    return dict;
  },
  {
    en: {},
    es: {}
  }
);

const t = translateWithDictionary(
  merge(
    {},
    dictionary,
    ratingDictionary,
    ratingFieldDictionary,
    ratingBreakdownFieldDictionary
  )
);

const SortSelect = () => (
  <SortContext.Consumer>
    {({ sort, onSortChanged, sortOptions }) => {
      const options = sortOptions.map(k => ({ key: k, label: t(k) }));
      return (
        <Select
          objects={options}
          labelFunc={d => d.label}
          keyFunc={d => d.key}
          onChange={d => onSortChanged(d.key)}
          defaultLabel={
            (options.find(obj => obj.key === sort) || options[0]).label
          }
          defaultValue={sort}
          value={sort}
        />
      );
    }}
  </SortContext.Consumer>
);

export default SortSelect;

SortSelect.propTypes = {};

SortSelect.defaultProps = {};
