import React from 'react';
import SearchBox, { t, keyMap } from './search_box';
import { SM, XS, validSizes, viewport } from 'util/viewport';
import { debounce } from 'lodash';
import { translateWithDictionary } from 'util/i18n';

export default class ReviewPageSearchBox extends SearchBox {

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

  // # add callback to calling class
  shouldShowAutoComplete(q) {
    let return_value = false;
    if(q.length >= 3) {
      console.log("show link");
      this.props.statusCallback(true);
      return_value = true;
    }
    else {
      console.log("hide link");
      this.props.statusCallback(false);
      return_value = false;
    }
    return return_value;
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

  render() {
    return (
      <React.Fragment>
             <div className="subtitle-sm tac">
               <a className="js-doNotSeeResult dn pointer">
                 {t('.do_not_see_school_text')}Do not see School?
              </a>
            </div>
          {this.searchBoxElement(false)}
      </React.Fragment>
    )
  }

}
