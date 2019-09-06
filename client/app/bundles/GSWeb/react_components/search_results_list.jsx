import React from 'react';
import PropTypes from 'prop-types';
import { href } from 'util/search';
import { translateWithDictionary, capitalize } from 'util/i18n';
import poweredByGoogle from 'search/powered_by_google_on_white.png';

const t = translateWithDictionary({
  en: {
    'Search all results for': 'Search all results for {searchTerm}',
    'Schools in': 'Schools in {location}',
    'Schools near': 'Schools near {location}'
  },
  es: {
    'Search all results for': 'Buscar todos los resultados para {searchTerm}',
    Addresses: 'Direcciones',
    Zipcodes: 'Códigos ZIP',
    Districts: 'Distritos',
    Cities: 'Ciudades',
    Schools: 'Escuelas',
    'Schools in': 'Escuelas en {location}',
    'Schools near': 'Escuelas cerca de {location}'
  }
});

const boldSearchTerms = (string, substring) => {
  const tokens = substring.trim().split(/,|\s+/);
  // The following separates string into chunks of matching and non matching substrings
  // We cannot inject a variable into a regex literal, hence 'new RegExp'. Noteworthy that split returns the matched
  // string when fed a group-capturing regex (compare 'Some string'.split(' '), which returns ['some','string'], not ['some',' ','string']
  let cleanTokens = tokens.join('*****').replace(/[^a-zA-Z 0-9\-\,\']\s+/g,'').split('*****');
  const matchesAndNonMatches = string.split(
    new RegExp(`\\b(${cleanTokens.join('|')})`, 'gi')
  );
  return matchesAndNonMatches.map((token, i) => {
    const queryContainsToken = tokens.find(
      item => item.toLowerCase() === token.toLowerCase()
    );
    if (queryContainsToken) {
      return (
        <span key={token + i} className="match">
          {token}
        </span>
      );
    }
    return token;
  });
};

const resultTypes = {
  Schools: {
    title: ({ school }) => school,
    additionalInfo: ({ city, state, zip }) => `${city}, ${state} ${zip || ''}`
  },
  Cities: {
    title: ({ city, state }) =>
      t('Schools in', { parameters: { location: `${city}, ${state}` } }),
    additionalInfo: () => null
  },
  Districts: {
    title: ({ district }) =>
      t('Schools in', { parameters: { location: district } }),
    additionalInfo: ({ city, state }) => `${city}, ${state}`
  },
  Zipcodes: {
    title: ({ value }) =>
      t('Schools near', { parameters: { location: value } }),
    additionalInfo: () => null
  },
  Addresses: {
    title: ({ value }) =>
      t('Schools near', { parameters: { location: value } }),
    additionalInfo: () => null
  }
};

// This component is responsible for formatting and rendering a payload of search results (listGroups) into a dropdown.
// Noteworthy behavior: 1) within the title of each listItem, it will bold substrings that match the searchTerm,
// 2) onclick, it will invoke the onSelect callback if a listItem does not have a url. In the current implementation, SearchBox
// houses the callback, and updates the value of the input with the value of the listItem, then submits a search. 3) if a list item
// is selected and the user hits the return key, that event is handled by the search box.
const SearchResultsList = ({
  selectedListItem,
  onSelect,
  listGroups,
  searchTerm,
  showSearchAllOption
}) => {
  const groupNameListItem = (name, index) => (
    <li key={`category ${name}`} className="search-results-list-group-name clearfix">
      <div className='fl'>{t(capitalize(name))}</div>
      {index == 0 && <div className='fr'><img src={poweredByGoogle}/></div>}
    </li>
  );

  const groupListItems = (group, listItems, order) => 
    listItems.map(listItem => {
      order.counter += 1;
      const title = resultTypes[group].title(listItem);
      const additionalInfo = resultTypes[group].additionalInfo(listItem);
      return (
        <li
          onClick={listItem.url ? () => {} : () => onSelect(listItem)}
          key={group + title + listItem.url}
          className={`search-results-list-item${
            order.counter === selectedListItem ? ' selected' : ''
          }`}
        >
          <a href={href(listItem.url)}>
            <div>{boldSearchTerms(title, searchTerm)}</div>
            <div>{additionalInfo}</div>
          </a>
        </li>
      );
    }, this);

  // The last <li> is always an option to do a full search using the current search term (i.e. without clicking the search icon)
  const allResultsListItem = () => (
    <li
      className="search-results-show-all-option"
      onClick={() => {
        analyticsEvent('autosuggest', 'search all results', searchTerm);
        onSelect({ value: searchTerm });
      }}
    >
      {t('Search all results for', { parameters: { searchTerm } })}
    </li>
  );

  const renderList = () => {
    const order = { counter: -1 };
    return Object.keys(listGroups)
      .filter(k => listGroups[k] && listGroups[k].length > 0)
      .map((group, index) => (
        <React.Fragment key={group}>
          {groupNameListItem(group, index)}
          {groupListItems(group, listGroups[group], order)}
        </React.Fragment>
      ));
  };

  return (
    <ul>
      {renderList()}
      {showSearchAllOption && allResultsListItem()}
    </ul>
  );
};

SearchResultsList.propTypes = {
  onSelect: PropTypes.func.isRequired,
  selectedListItem: PropTypes.number,
  listGroups: PropTypes.object,
  searchTerm: PropTypes.string,
  showSearchAllOption: PropTypes.bool
};

SearchResultsList.defaultProps = {
  showSearchAllOption: true
}

export default SearchResultsList;
