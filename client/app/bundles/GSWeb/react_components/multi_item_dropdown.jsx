import React from 'react';
import PropTypes from 'prop-types';

const MultiItemDropdown = ({ listGroups, searchTerm }) => {
  const boldSubstring = string => {
    const substringIdx = string.indexOf(searchTerm);
    if (substringIdx === -1) {
      return;
    }
    const allSubstrings = [];
    allSubstrings.push(string.slice(0, substringIdx));
    allSubstrings.push(
      string.slice(substringIdx, searchTerm.length + substringIdx)
    );
    allSubstrings.push(string.slice(substringIdx + searchTerm.length));
    const nonEmptySubs = allSubstrings.filter(str => str.length > 0);
    const stringWithMarkup = nonEmptySubs.map(str => (
      <span style={str === searchTerm ? { fontWeight: 700 } : {}}>{str}</span>
    ));
    return stringWithMarkup;
  };
  const groupNameListItem = name => (
    <li className="multi-item-select-group-name">{name}</li>
  );
  const groupListItems = listItems =>
    listItems.map((listItem, idx) => (
      <li className="multi-item-select-list-item">
        <a key={listItem.title + idx.toString()} href={listItem.url}>
          <div>{boldSubstring(listItem.title)}</div>
          <div>{listItem.additionalInfo}</div>
        </a>
      </li>
    ));

  const renderList = (listData = {}) =>
    Object.keys(listData).map(group => (
      <React.Fragment>
        {groupNameListItem(group)}
        {groupListItems(listGroups[group].listItems)}
      </React.Fragment>
    ));
  return (
    <div className="multi-item-dropdown">
      <ul>{renderList(listGroups)}</ul>
    </div>
  );
};

export default MultiItemDropdown;
