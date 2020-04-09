import React from 'react';
import SearchBox, { keyMap } from './search_box';
import { t } from 'util/i18n';
import {hasClass, addClass, removeClass} from 'util/selectors';

class ReviewPageSearchBox extends SearchBox {

  constructor(props) {
    super(props);
  }

  urlOspUrl(selectedItem){
    if(this.props.osp){
      return selectedItem.ospUrl;
    }
    else{
      return selectedItem.url;
    }
  }

  callbackToggle(){
    this.props.statusCallback(false);
  }

  searchResultsList = ({ close }) => {
    const ListType = this.props.listType;
    return (
      <ListType
        listGroups={this.state.autoSuggestResults}
        searchTerm={this.state.searchTerm}
        onSelect={this.selectAndSubmit(close)}
        selectedListItem={this.state.selectedListItem}
        navigateToSelectedListItem={this.state.navigateToSelectedListItem}
        showSearchAllOption={this.props.showSearchAllOption}
      />
    );
  };

  sortResultsByCategory(results) {
    const adaptedResults = {
      Addresses: [],
      Zipcodes: [],
      Cities: [],
      Districts: [],
      Schools: []
    };
    Object.keys(results).forEach(category => {
      (results[category] || []).forEach(result => {
        // sets the url link as the OSP for OSP related pages
        if(this.props.osp){
          result.url = result.ospUrl;
        }
        adaptedResults[category].push(result);
      });
    });
    adaptedResults.Addresses = this.state.autoSuggestResults.Addresses;
    this.setState({ autoSuggestResults: adaptedResults });
  }

  handleKeyDown(e, { close }) {
    if (e.key === 'Enter') {
      if (this.state.selectedListItem > -1) {
        close();
        const flattenedResultValues = Array.prototype.concat.apply(
          [],
          Object.values(this.state.autoSuggestResults).filter(array => !!array)
        );
        const selectedListItem = flattenedResultValues[this.state.selectedListItem];
        if (this.urlOspUrl(selectedListItem)) {
          window.location.href = this.urlOspUrl(selectedListItem);
        }
        else {
          this.selectAndSubmit(() => {})(selectedListItem);
        }
      }
    } else if (Object.keys(keyMap).includes(e.key)) {
      this.manageSelectedListItem(e);
    }
  }

  transformResult(category, result) {
    if(category == 'Schools') {
      return ({...result, url: this.urlOspUrl(result)});
    }
  }

  onQueryMatchesAddress(q) {}

  placeholderText() {
    return t('Enter school');
  }

  displayDoNotSeeSchoolLink(){
    const subtitleHeight = {
      height: '35px'
    };
    if (this.state.searchTerm.length >= 3){
      return(
        <div className="subtitle-sm tac" style={subtitleHeight}>
          <a style={{cursor: 'pointer'}} onClick={this.props.showStateSelector}>
            {t('school_picker.do_not_see_school_text')}
          </a>
        </div>
      );
    }else{
      return <div className="subtitle-sm tac" style={subtitleHeight}></div>;
    }
  }

  render() {
    return (
      <React.Fragment>
        {this.displayDoNotSeeSchoolLink()}
        <div className="search-bar-osp js-autocompleteFieldContainer ma picker-border">
          <div className="full-width">
            {this.searchBoxElement(false)}
          </div>
        </div>
      </React.Fragment>
    )
  }
}

export default ReviewPageSearchBox;