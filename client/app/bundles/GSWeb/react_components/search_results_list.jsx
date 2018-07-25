import React from 'react';
import PropTypes from 'prop-types';
import { href } from 'util/search';

const boldSearchTerms = (string, substring) => {
  const tokens = substring.trim().split(/\s+/);
  // The following separates string into chunks of matching and non matching substrings
  // We cannot inject a variable into a regex literal, hence 'new RegExp'. Noteworthy that split returns the matched
  // string when fed a group-capturing regex (compare 'Some string'.split(' '), which returns ['some','string'], not ['some',' ','string']
  const matchesAndNonMatches = string.split(
    new RegExp(`\\b(${tokens.join('|')})`, 'gi')
  );
  return matchesAndNonMatches.map(token => {
    const queryContainsToken = tokens.find(
      item => item.toLowerCase() === token.toLowerCase()
    );
    if (queryContainsToken) {
      return (
        <span key={token} className="match">
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
    title: ({ city, state }) => `Schools in ${city}, ${state}`,
    additionalInfo: () => null
  },
  Districts: {
    title: ({ district }) => `Schools in ${district}`,
    additionalInfo: ({ city, state }) => `${city}, ${state}`
  },
  Zipcodes: {
    title: ({ zip }) => `Schools in ${zip}`,
    additionalInfo: () => null
  },
  Addresses: {
    title: ({ address }) => `Schools near ${address}`,
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
  searchTerm
}) => {
  const groupNameListItem = name => (
    <li key={`category ${name}`} className="search-results-list-group-name">
      {name[0].toUpperCase() + name.slice(1)}
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
          key={listItem.title + listItem.url}
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
      className="search-results-list-item"
      onClick={() => onSelect({ value: searchTerm })}
    >
      {`Search all results for "${searchTerm}"`}
    </li>
  );

  const renderList = () => {
    const order = { counter: -1 };
    return Object.keys(listGroups)
      .filter(k => listGroups[k] && listGroups[k].length > 0)
      .map(group => (
        <React.Fragment key={group}>
          {groupNameListItem(group)}
          {groupListItems(group, listGroups[group], order)}
        </React.Fragment>
      ));
  };

  return (
    <ul>
      {renderList()}
      {allResultsListItem()}
    </ul>
  );
};

SearchResultsList.propTypes = {
  onSelect: PropTypes.func.isRequired,
  selectedListItem: PropTypes.number,
  listGroups: PropTypes.object,
  searchTerm: PropTypes.string
};

export default SearchResultsList;
