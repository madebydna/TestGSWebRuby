import React from 'react';
import PropTypes from 'prop-types';

// Given a group of siblings, allow multiple to be selected by the user
// Selecting one item unselects other items
// When items are selected/unselected, onSelect is called with the active items
export default class MultiItemSelectable extends React.Component {
  static propTypes = {
    options: PropTypes.object.isRequired, // object with {e: 'Elementary', m: 'Middle', ...}
    activeOptions: PropTypes.arrayOf(PropTypes.string), // Options active by default. e.g. ['e','m']
    onSelect: PropTypes.func.isRequired, // called with selected options each time state is changed
  }

  static defaultProps = {
    activeOptions: []
  }

  constructor(props) {
    super(props);
    this.state = {
      optionState: this.activeOptionsAsObject(props.activeOptions) // { key: true/false }
    }
  }

  activeOptionsAsObject(activeOptions) {
    return Object.keys(this.props.options).reduce(
      (obj, option) => {
        obj[option] = activeOptions && activeOptions.indexOf(option) >= 0
        return obj;
      }, {}
    )
  }

  componentWillReceiveProps(nextProps) {
    if(nextProps.activeOptions && nextProps.activeOptions != this.props.activeOptions) {
      this.setState({ optionState: this.activeOptionsAsObject(nextProps.activeOptions) });
    }
  }

  getNewOptionState(chosenOption) {
    let newOptions = {...this.state.optionState};
    newOptions[chosenOption] = !newOptions[chosenOption];
    return newOptions;
  }

  // the keys of selected items. Such as ['e','h']
  getSelectedOptions() {
    return Object.keys(this.state.optionState)
      .filter(o => this.state.optionState[o] == true);
  }

  handleSelect(option) {
    return () => {
      this.setState(
        { optionState: this.getNewOptionState(option)},
        () => this.props.onSelect(this.getSelectedOptions())
      );
    }
  }

  isOptionActive(option) {
    return this.state.optionState[option];
  }

  render() {
    return <React.Fragment>
      {
        Object.keys(this.props.options) // [e,m,h,p]
        .map(option => 
          React.cloneElement(
            this.props.children(
              option,
              this.props.options[option],
              this.isOptionActive(option) 
            ),
            {
              onClick: this.handleSelect(option)
            } // extra props added to new element
          )
        )
      }
    </React.Fragment>
  }

}
