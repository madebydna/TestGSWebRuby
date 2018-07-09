import React from 'react';
import PropTypes from 'prop-types';
import { copyParam } from 'util/uri';
import { capitalize } from 'util/i18n';
import { escapeRegexChars, everythingButHTML } from 'util/regex';

// This component is responsible for formatting and rendering a payload of search results (listGroups) into a dropdown.
// It is stateless.
// Noteworthy behavior: 1) within the title of each listItem, it will bold substrings that match the searchTerm,
// 2) it will invoke the onSelect callback if a listItem does not have a url. In the current implementation, SearchBox
// houses the callback, and updates the value of the input with the value of the listItem, then submits a search.

const SearchResultsList = ({ listGroups, searchTerm, onSelect, listItemsSelectable }) => {
  const href = url =>
    url
      ? copyParam(
          'newsearch',
          window.location.href,
          copyParam('lang', window.location.href, url)
        )
      : undefined;

  const boldSearchTerms = (string, substring)=>{
    // let splitSub = substring.split(' ').filter(str=>str.length > 0);
    // let substringsBolded = string;
    // splitSub.forEach((sub, idx)=>{
    //   // Need to preserve capitalization in original string
    //   let match = string.match(new RegExp(sub, 'i'))
    //   if (match){
    //     //This loop adds html tags to a string, so we need to avoid matching anything in those tags. After disregarding
    //     // text following < and preceding >, replace the match with the span.
    //     substringsBolded = everythingButHTML(substringsBolded).replace(match, `<span class="match">${match}</span>`)
    //   }
    // });
    return string
  }

  const groupNameListItem = name => (
    <li className="search-results-list-group-name">
      {name[0].toUpperCase() + name.slice(1)}
    </li>
  );
  const groupListItems = listItems =>
    listItems.map(
      (listItem, idx) => (
        <li
          onClick={listItem.url ? () => {} : () => onSelect(listItem.value)}
          key={listItem.title + idx.toString()}
          className="search-results-list-item"
        >
          <a href={href(listItem.url)}>
            <div dangerouslySetInnerHTML={{__html: boldSearchTerms(listItem.title)}}></div>
            {/*<div>{boldSearchTerms(listItem.title, searchTerm)}</div>*/}
            <div>{listItem.additionalInfo}</div>
          </a>
        </li>
      ),
      this
    );

  const renderList = (listData = {}) =>
    Object.keys(listData)
      .filter(k => listData[k].length > 0)
      .map(
        group => (
          <React.Fragment>
            {groupNameListItem(group)}
            {groupListItems(listGroups[group])}
          </React.Fragment>
        ),
        this
      );
  return (
    <ul>{renderList(listGroups)}</ul>
  );
};

SearchResultsList.propTypes = {
  onSelect: PropTypes.func.isRequired
};

export default SearchResultsList;
