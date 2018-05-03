import PropTypes from 'prop-types';
import MultiItemSelectable from './multi_item_selectable';

// Given a group of siblings, allow one to be selected by the user
// Selecting one item unselects other items
// When an item is selected/unselected, onSelect is called with the active item
export default class SingleItemSelectable extends MultiItemSelectable {
  static propTypes = {
    options: PropTypes.arrayOf(
      PropTypes.shape({
        key: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
        value: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
        label: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
        allowDeselect: PropTypes.boolean // default true
      })
    ).isRequired,
    activeKeys: PropTypes.arrayOf(
      PropTypes.oneOfType([PropTypes.string, PropTypes.number])
    ), // Options active by default. e.g. ['e','m']
    onSelect: PropTypes.func.isRequired, // called with active keys when option selected
    onDeselect: PropTypes.func, // called with active keys when option is deselected. Defaults to onSelect function
    children: PropTypes.func.isRequired
  };

  // overrides parent class method
  selectKey(key, func) {
    this.setState(
      {
        activeKeys: [key]
      },
      func
    );
  }

  // overrides parent class method
  getSelectedValues() {
    return super.getSelectedValues()[0];
  }
}
