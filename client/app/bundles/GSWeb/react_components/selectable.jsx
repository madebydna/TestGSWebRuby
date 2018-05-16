import React from 'react';
import PropTypes from 'prop-types';

// Given a group of siblings, allow one or multiple to be selected by the user
// Selecting one item unselects other items
// When items are selected/unselected, onSelect is called with the active item(s)
export default class Selectable extends React.Component {
  static propTypes = {
    multiple: PropTypes.bool,
    options: PropTypes.arrayOf(PropTypes.object).isRequired,
    activeOptions: PropTypes.arrayOf(
      PropTypes.oneOfType([PropTypes.object, PropTypes.string])
    ),
    onSelect: PropTypes.func.isRequired, // called with active keys when option selected
    onDeselect: PropTypes.func, // called with active keys when option is deselected. Defaults to onSelect function
    children: PropTypes.func.isRequired,
    allowDeselect: PropTypes.bool,
    keyFunc: PropTypes.func
  };

  static defaultProps = {
    multiple: false,
    activeOptions: [],
    onDeselect: null,
    allowDeselect: true,
    keyFunc: null
  };

  getSelectedOptions() {
    if (this.props.multiple) {
      return this.props.activeOptions;
    }
    return this.props.activeOptions[0];
  }

  isOptionSelected(option) {
    return this.props.activeOptions.indexOf(option) > -1;
  }

  selectOption(option) {
    let activeOptions = [option];
    if (this.props.multiple) {
      activeOptions = this.props.activeOptions.concat(option);
    }
    return activeOptions;
  }

  deselectOption(option) {
    return this.props.activeOptions.filter(o => o !== option);
  }

  handleSelect(option) {
    let k = option;
    if (this.props.keyFunc) {
      k = this.props.keyFunc(option);
    }
    if (this.isOptionSelected(k)) {
      if (this.props.allowDeselect !== false) {
        const func = this.props.onDeselect || this.props.onSelect;
        func(this.deselectOption(k));
      }
    } else {
      this.props.onSelect(this.selectOption(k));
    }
  }

  render() {
    return (
      <React.Fragment>
        {this.props.children(
          this.props.options.map(option => {
            let k = option;
            if (this.props.keyFunc) {
              k = this.props.keyFunc(option);
            }

            return {
              option,
              active: this.isOptionSelected(k),
              select: () => this.handleSelect(option)
            };
          })
        )}
      </React.Fragment>
    );
  }
}
