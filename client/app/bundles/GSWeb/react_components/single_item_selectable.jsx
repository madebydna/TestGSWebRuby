import PropTypes from 'prop-types';
import MultiItemSelectable from './multi_item_selectable';

// Given a group of siblings, allow one to be selected by the user
// Selecting one item unselects other items
// When an item is selected/unselected, onSelect is called with the active item
export default class SingleItemSelectable extends MultiItemSelectable {
  static propTypes = {
    options: PropTypes.arrayOf(PropTypes.object).isRequired,
    activeOptions: PropTypes.arrayOf(PropTypes.object), // Options active by default. e.g. ['e','m']
    onSelect: PropTypes.func.isRequired, // called with active keys when option selected
    onDeselect: PropTypes.func, // called with active keys when option is deselected. Defaults to onSelect function
    children: PropTypes.func.isRequired,
    allowDeselect: PropTypes.bool
  };

  // overrides parent class method
  selectOption(option, func) {
    this.setState(
      {
        activeOptions: [option]
      },
      func
    );
  }

  // overrides parent class method
  getSelectedOptions() {
    return super.getSelectedOptions()[0];
  }
}
