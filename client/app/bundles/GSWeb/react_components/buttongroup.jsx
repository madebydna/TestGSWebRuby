import React from 'react';
import PropTypes from 'prop-types';
import Selectable from './selectable';

export default class ButtonGroup extends React.Component {
  static propTypes = {
    options: PropTypes.object.isRequired,
    onSelect: PropTypes.func.isRequired,
    activeOption: PropTypes.string
  };

  render() {
    const newOpts = Object.keys(this.props.options).map(key => ({
      key,
      value: key,
      label: this.props.options[key]
    }));

    return (
      <span className="button-group">
        <Selectable
          options={newOpts}
          activeOptions={newOpts.filter(o => o.key === this.props.activeOption)}
          onSelect={({ key }) => this.props.onSelect(key)}
          className="button-group"
        >
          {opts =>
            opts.map(option => (
              <label
                key={option.key}
                className={active ? 'active' : ''}
                onClick={select}
                onKeyPress={select}
                role="button"
              >
                {option.label}
              </label>
            ))
          }
        </Selectable>
      </span>
    );
  }
}
