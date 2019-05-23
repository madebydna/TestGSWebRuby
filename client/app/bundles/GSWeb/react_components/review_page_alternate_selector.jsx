import React from 'react';
// import PropTypes from 'prop-types';
// import SearchBox, { t, keyMap } from './search_box';
import { SM, XS, validSizes, viewport } from 'util/viewport';
import { debounce } from 'lodash';
import { translateWithDictionary } from 'util/i18n';
import { stateAbbreviations } from 'util/states';

export default class ReviewPageAlternateSelector extends React.Component  {
  constructor(props) {
    super(props);
    // this.handleKeyDown = this.handleKeyDown.bind(this);
    // this.resetSelectedListItem = this.resetSelectedListItem.bind(this);
    // this.resetSearchTerm = this.resetSearchTerm.bind(this);
    // this.manageSelectedListItem = this.manageSelectedListItem.bind(this);
    // this.state = this.defaultState(props);
    // this.submit = this.submit.bind(this);
    // this.geocodeAndSubmit = this.geocodeAndSubmit.bind(this);
    // this.autoSuggestQuery = debounce(this.autoSuggestQuery.bind(this), 200);
  }

  // handleKeyDown(e, { close }) {
  //   if (e.key === 'Enter') {
  //     if (this.state.selectedListItem > -1) {
  //       close();
  //       const flattenedResultValues = Array.prototype.concat.apply(
  //           [],
  //           Object.values(this.state.autoSuggestResults).filter(array => !!array)
  //       );
  //       const selectedListItem =
  //           flattenedResultValues[this.state.selectedListItem];
  //       if (selectedListItem.url) {
  //         window.location.href = selectedListItem.url;
  //       } else {
  //         this.selectAndSubmit(() => {})(selectedListItem);
  //       }
  //     }
  //   } else if (Object.keys(keyMap).includes(e.key)) {
  //     this.manageSelectedListItem(e);
  //   }
  // }

  // needs a callback function
  shouldShowAutoComplete(q) {
    let return_value = false;
    if(q.length >= 3) {
      console.log("show link");
      return_value = true;
    }
    else {
      console.log("hide link");
      return_value = false;
    }
    return return_value;
  }

  onQueryMatchesAddress(q) {}

  placeholderText() {
    return t('Enter school');
  }
  dontSeeYourSchoolContainer() {
    return ( <a className="js-doNotSeeResult pointer search-link-black" data-no-result-text="Don't see your school?"
                data-return-to-search-text="Return to original search" data-state="">
          Don't see your school?
        </a>
    )
  }

  dontSeeYourSchoolContainer(){
    return ( <div className="subtitle-sm tac" style="height:35px;">
          {this.dontSeeYourSchoolContainer()}
        </div>
    )
  }

  render() {

    // let elements = window.document.querySelectorAll('.dt-desktop');
    // // if (this.props.size <= SM) {
    // //   return [...elements].map(element => this.renderMobileSearchBox(element))
    // // }
    // return Array.from(elements).map(element => this.renderSearchBox(element, false))
    return (
        <React.Fragment>
          {/*{this.dontSeeYourSchoolContainer()}*/}
          {/*{this.searchBoxElement(false)}*/}
          {this.stateCitySchoolSelect()}
        </React.Fragment>
    )
  }



  stateCitySchoolSelect() {
    this.state_option_list = stateAbbreviations.map((state, key) =>
        <option value="{state}">{state.toUpperCase()}</option>
    );
    return (
        <div className="ma picker-border picker-background" style="max-width: 600px;">
          <select value={this.state.value} onChange={this.handleChange} className="notranslate">
            <option value="">Select state</option>
            {this.state_option_list}
          </select>
          <select className="form-control js-citySelect dn mtm notranslate"></select>
          <select className="form-control js-schoolSelect mtm dn notranslate"></select>
        </div>
    )
  }

}
