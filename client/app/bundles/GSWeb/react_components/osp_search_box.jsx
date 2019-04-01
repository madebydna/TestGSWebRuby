import React from 'react';
import PropTypes from 'prop-types';
import SearchBox, { t, keyMap } from './search_box';
import { SM, XS, validSizes, viewport } from 'util/viewport';
import { debounce } from 'lodash';
import { translateWithDictionary } from 'util/i18n';

export default class OspSearchBox extends SearchBox {
  constructor(props) {
    super(props);
    this.handleKeyDown = this.handleKeyDown.bind(this);
    this.resetSelectedListItem = this.resetSelectedListItem.bind(this);
    this.resetSearchTerm = this.resetSearchTerm.bind(this);
    this.manageSelectedListItem = this.manageSelectedListItem.bind(this);
    this.state = this.defaultState(props);
    this.submit = this.submit.bind(this);
    this.geocodeAndSubmit = this.geocodeAndSubmit.bind(this);
    this.autoSuggestQuery = debounce(this.autoSuggestQuery.bind(this), 200);
  }

  handleKeyDown(e, { close }) {
    if (e.key === 'Enter') {
      if (this.state.selectedListItem > -1) {
        close();
        const flattenedResultValues = Array.prototype.concat.apply(
          [],
          Object.values(this.state.autoSuggestResults).filter(array => !!array)
        );
        const selectedListItem =
          flattenedResultValues[this.state.selectedListItem];
        if (selectedListItem.ospUrl) {
          window.location.href = selectedListItem.ospUrl;
        } else {
          this.selectAndSubmit(() => {})(selectedListItem);
        }
      }
    } else if (Object.keys(keyMap).includes(e.key)) {
      this.manageSelectedListItem(e);
    }
  }

  transformResult(category, result) {
    if(category == 'Schools') {
      return ({...result, url: result.ospUrl});
    }
  }

  onQueryMatchesAddress(q) {}

  placeholderText() {
    return t('Enter school');
  }

  render() {
    // let elements = window.document.querySelectorAll('.dt-desktop');
    // // if (this.props.size <= SM) {
    // //   return [...elements].map(element => this.renderMobileSearchBox(element))
    // // }
    // return Array.from(elements).map(element => this.renderSearchBox(element, false))
    return this.searchBoxElement(false)
  }

}
