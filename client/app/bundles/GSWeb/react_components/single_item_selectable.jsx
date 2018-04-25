import React from 'react';
import PropTypes from 'prop-types';
import MultiItemSelectable from './multi_item_selectable';

// Given a group of siblings, allow one to be selected by the user
// Selecting one item unselects other items
// When an item is selected/unselected, onSelect is called with the active item
export default class SingleItemSelectable extends MultiItemSelectable {
  static propTypes = {
    options: PropTypes.object.isRequired,
    activeOption: PropTypes.string,
    onSelect: PropTypes.func.isRequired
  }

  constructor(props) {
    super({...props, activeOptions: [props.activeOption]});
  }

  // overrides parent class method
  getNewOptionState(chosenOption) {
    if (this.isOptionActive(chosenOption)) {
      chosenOption = null;
    } 
    return this.activeOptionsAsObject([chosenOption]);
  }

  // overrides parent class method
  getSelectedOptions() {
    return super.getSelectedOptions()[0];
  }
}
