import React from 'react';
import PropTypes from 'prop-types';
import {copyParam} from 'util/uri';

// This component is responsible for formatting and rendering a payload of search results (listGroups) into a dropdown.
// Noteworthy behavior: 1) within the title of each listItem, it will bold substrings that match the searchTerm,
// 2) it will invoke the onSelect callback if a listItem does not have a url. In the current implementation, SearchBox
// houses the callback, and updates the value of the input with the value of the listItem, then submits a search.
class SearchResultsList extends React.Component {
  constructor(props) {
    super(props)
    let {selectedListItem, navigateToSelectedListItem} = this.props;
    this.state = {selectedListItem: selectedListItem}
    this.counter = -1
  }

  href(url) {
    return (url
      ? copyParam(
        'newsearch',
        window.location.href,
        copyParam('lang', window.location.href, url)
      )
      : undefined)
  }

  boldSearchTerms(string, substring) {
    let tokens = substring.split(/\s+/)
    //The following separates string into chunks of matching and non matching substrings
    //We cannot inject a variable into a regex literal, hence 'new RegExp'. Noteworthy that split returns the matched
    //string when fed a group-capturing regex (compare 'Some string'.split(' '), which returns ['some','string'], not ['some',' ','string']
    let matchesAndNonMatches = string.split(new RegExp(`\\b(${tokens.join('|')})`, 'gi'))
    return matchesAndNonMatches.map(token => {
      let queryContainsToken = tokens.find(item => item.toLowerCase() === token.toLowerCase())
      if(queryContainsToken) {
        return <span className="match">{token}</span>
      }
      return token;
    })
  }

  groupNameListItem(name) {
    return (<li className="search-results-list-group-name">
      {name[0].toUpperCase() + name.slice(1)}
    </li>)
  }

  componentDidUpdate(prevProps){
    this.counter = -1
    if (prevProps.selectedListItem !== this.props.selectedListItem) {
      this.setState({selectedListItem: this.props.selectedListItem})
    }
  }

  changeUrlIfSelected(listItem, key){
    this.props.navigateToSelectedListItem && listItem.url && this.counter === this.state.selectedListItem && (window.location.href = listItem.url + '?newsearch')
  }

  groupListItems(listItems) {
    let {searchTerm,onSelect} = this.props;
    return (listItems.map(
        (listItem, idx) => {
          this.counter += 1
          this.changeUrlIfSelected(listItem, idx)
          return (
            <li
              onClick={listItem.url ? () => {
              } : () => onSelect(listItem.value)}
              key={listItem.title}
              className={"search-results-list-item" + (this.counter === this.state.selectedListItem ? " selected" : '')}
            >
              <a href={this.href(listItem.url)}>
                <div>{this.boldSearchTerms(listItem.title, searchTerm)}</div>
                <div>{listItem.additionalInfo}</div>
              </a>
            </li>
          )
        },
        this
      )
    )
  }

  // The last <li> is always an option to do a full search using the current search term (i.e. without clicking the search icon)
  allResultsListItem(){
    let {searchTerm,onSelect} = this.props;
    return <li className="search-results-list-item" onClick={()=> onSelect(searchTerm)}>{`Search all results for "${searchTerm}"`}</li>
  }

  renderList(listData) {
    let {listGroups} = this.props;
    return (Object.keys(listGroups)
        .filter(k => listGroups[k].length > 0)
        .map(
          group => (
            <React.Fragment>
              {this.groupNameListItem(group)}
              {this.groupListItems(listGroups[group])}
            </React.Fragment>
          ),
          this
        )
    )
  }

  render() {
    return (
      <ul>
        {this.renderList()}
        {this.allResultsListItem()}
      </ul>
    )
  }
}

SearchResultsList.propTypes = {
  onSelect: PropTypes.func.isRequired
};

export default SearchResultsList;
