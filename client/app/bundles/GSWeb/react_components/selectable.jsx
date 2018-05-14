import React from 'react';
import PropTypes from 'prop-types';

// Given a group of siblings, allow one or multiple to be selected by the user
// Selecting one item unselects other items
// When items are selected/unselected, onSelect is called with the active item(s)
export default class Selectable extends React.Component {
  static propTypes = {
    multiple: PropTypes.bool,
    options: PropTypes.arrayOf(PropTypes.object).isRequired,
    activeOptions: PropTypes.arrayOf(PropTypes.object),
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

  constructor(props) {
    super(props);
    this.state = {
      activeOptions: props.activeOptions
    };
  }

  getSelectedOptions() {
    if (this.props.multiple) {
      return this.state.activeOptions;
    }
    return this.state.activeOptions[0];
  }

  isOptionSelected(option) {
    return this.state.activeOptions.indexOf(option) > -1;
  }

  selectOption(option, func) {
    let activeOptions = [option];
    if (this.props.multiple) {
      activeOptions = this.state.activeOptions.concat(option);
    }
    this.setState({ activeOptions }, func);
  }

  deselectOption(option, func) {
    this.setState(
      {
        activeOptions: this.state.activeOptions.filter(o => o !== option)
      },
      func
    );
  }

  handleSelect(option) {
    let k = option;
    if (this.props.keyFunc) {
      k = this.props.keyFunc(option);
    }
    if (this.isOptionSelected(k)) {
      if (this.props.allowDeselect !== false) {
        this.deselectOption(k, () => {
          const func = this.props.onDeselect || this.props.onSelect;
          func(this.getSelectedOptions());
        });
      }
    } else {
      this.selectOption(k, () => {
        this.props.onSelect(this.getSelectedOptions());
      });
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
