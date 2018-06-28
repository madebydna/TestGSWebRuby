import React from 'react';
import PropTypes from 'prop-types';

const MultiItemDropdown = ({ listGroups, searchTerm }) => {
  const boldSubstring = string => {
    const substringMatch = string.match(new RegExp(searchTerm, 'i'));
    if (!substringMatch) {
      return string;
    }
    const allSubstrings = [];
    allSubstrings.push(string.slice(0, substringMatch.index));
    allSubstrings.push(
      string.slice(
        substringMatch.index,
        searchTerm.length + substringMatch.index
      )
    );
    allSubstrings.push(string.slice(substringMatch.index + searchTerm.length));
    const nonEmptySubs = allSubstrings.filter(str => str.length > 0);
    const stringWithMarkup = nonEmptySubs.map(str => (
      <span
        className={
          str.toLowerCase() === searchTerm.toLowerCase() ? 'match' : ''
        }
      >
        {str}
      </span>
    ));
    return stringWithMarkup;
  };
  const groupNameListItem = name => (
    <li className="multi-item-select-group-name">
      {name[0].toUpperCase() + name.slice(1)}
    </li>
  );
  const groupListItems = listItems =>
    listItems.map(
      (listItem, idx) => (
        <li
          key={listItem.title + idx.toString()}
          className="multi-item-select-list-item"
        >
          <a href={listItem.url}>
            <div>{boldSubstring(listItem.title)}</div>
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
    <div className="multi-item-dropdown">
      <ul>{renderList(listGroups)}</ul>
    </div>
  );
};

export default MultiItemDropdown;
