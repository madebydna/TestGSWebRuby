import React from 'react';
import PropTypes from 'prop-types';

// Given a group of siblings, allow multiple to be selected by the user
// Selecting one item unselects other items
// When items are selected/unselected, onSelect is called with the active items
export default class MultiItemSelectable extends React.Component {
  static propTypes = {
    options: PropTypes.arrayOf(
      PropTypes.shape({
        key: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
        value: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
        label: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
        allowDeselect: PropTypes.boolean, // default true
        allowSelect: PropTypes.bool // default true
      })
    ).isRequired,
    activeKeys: PropTypes.arrayOf(
      PropTypes.oneOfType([PropTypes.string, PropTypes.number])
    ), // Options active by default. e.g. ['e','m']
    onSelect: PropTypes.func.isRequired, // called with active keys when option selected
    onDeselect: PropTypes.func, // called with active keys when option is deselected. Defaults to onSelect function
    children: PropTypes.func.isRequired
  };

  static defaultProps = {
    activeKeys: [],
    onDeselect: null
  };

  constructor(props) {
    super(props);
    this.state = {
      activeKeys: this.filterOutInvalidKeys(props.activeKeys)
    };
  }

  filterOutInvalidKeys(keys) {
    if (!keys || !keys.filter) {
      return [];
    }
    return keys.filter(k => !!this.optionForKey(k));
  }

  componentWillReceiveProps(nextProps) {
    if (
      nextProps.activeKeys &&
      nextProps.activeKeys !== this.props.activeKeys
    ) {
      this.setState({
        activeKeys: this.filterOutInvalidKeys(nextProps.activeKeys)
      });
    }
  }

  getSelectedValues() {
    return this.state.activeKeys.map(
      k => (this.optionForKey(k) || {}).value || k
    );
  }

  isKeySelected(key) {
    return this.state.activeKeys.indexOf(key) > -1;
  }

  selectKey(key, func) {
    this.setState(
      {
        activeKeys: this.state.activeKeys.concat(key)
      },
      func
    );
  }

  deselectKey(key, func) {
    this.setState(
      {
        activeKeys: this.state.activeKeys.filter(k => k !== key)
      },
      func
    );
  }

  optionForKey(key) {
    return this.props.options.find(option => option.key === key);
  }

  handleSelect(key) {
    return () => {
      console.log('handle select');
      if (this.isKeySelected(key)) {
        if (this.optionForKey(key).allowDeselect !== false) {
          this.deselectKey(key, () => {
            const func = this.props.onDeselect || this.props.onSelect;
            func(this.getSelectedValues());
          });
        }
      } else if (this.optionForKey(key).allowSelect !== false) {
        this.selectKey(key, () => {
          this.props.onSelect(this.getSelectedValues());
        });
      }
    };
  }

  render() {
    return (
      <React.Fragment>
        {this.props.options.map(({ key, value, label }) =>
          React.cloneElement(
            this.props.children({
              key,
              value,
              label,
              active: this.isKeySelected(key)
            }),
            {
              key,
              onClick: this.handleSelect(key),
              onKeyPress: this.handleSelect(key)
            } // extra props added to new element
          )
        )}
      </React.Fragment>
    );
  }
}
