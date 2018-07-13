import React from 'react';
import PropTypes from 'prop-types';
import { castArray } from 'lodash';
import Selectable from './selectable';

const CheckboxGroup = ({
  options,
  onSelect,
  activeOption,
  multiple,
  label
}) => {
  const newOpts = Object.keys(options).map(key => ({
    key,
    value: key,
    label: options[key]
  }));

  return (
    <span className="checkbox-group" role="group" aria-label={label}>
      <Selectable
        options={newOpts}
        activeOptions={castArray(activeOption)}
        onSelect={key => onSelect(key)}
        keyFunc={o => o.key}
        multiple={multiple}
      >
        {opts =>
          opts.map(({ option, active, select }) => (
            <span key={option.key} onClick={select} onKeyPress={select}>
              <input
                name={option.key}
                type="checkbox"
                value={option.value}
                checked={active}
                readOnly
              />
              <label>{option.label}</label>
            </span>
          ))
        }
      </Selectable>
    </span>
  );
};

CheckboxGroup.propTypes = {
  options: PropTypes.object.isRequired,
  onSelect: PropTypes.func.isRequired,
  activeOption: PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.arrayOf(PropTypes.string)
  ]).isRequired,
  multiple: PropTypes.bool,
  label: PropTypes.string
};

CheckboxGroup.defaultProps = {
  multiple: false,
  label: undefined
};

export default CheckboxGroup;
