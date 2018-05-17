import React from 'react';
import PropTypes from 'prop-types';
import Selectable from './selectable';

const ButtonGroup = ({ options, onSelect, activeOption }) => {
  const newOpts = Object.keys(options).map(key => ({
    key,
    value: key,
    label: options[key]
  }));

  return (
    <span className="button-group">
      <Selectable
        options={newOpts}
        activeOptions={[activeOption]}
        onSelect={key => onSelect(key)}
        className="button-group"
        keyFunc={o => o.key}
      >
        {opts =>
          opts.map(({ option, active, select }) => (
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
};

ButtonGroup.propTypes = {
  options: PropTypes.object.isRequired,
  onSelect: PropTypes.func.isRequired,
  activeOption: PropTypes.string.isRequired
};

export default ButtonGroup;
