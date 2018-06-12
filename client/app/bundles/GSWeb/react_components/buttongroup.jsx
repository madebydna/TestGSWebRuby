import React from 'react';
import PropTypes from 'prop-types';
import { castArray } from 'lodash';
import Selectable from './selectable';
import Button from './button';

const ButtonGroup = ({
  options,
  onSelect,
  activeOption,
  multiple,
  label,
  allowDeselect
}) => {
  const newOpts = Object.keys(options).map(key => ({
    key,
    value: key,
    label: options[key]
  }));

  return (
    <span className="button-group" role="group" aria-label={label}>
      <Selectable
        options={newOpts}
        activeOptions={castArray(activeOption)}
        onSelect={key => onSelect(key)}
        keyFunc={o => o.key}
        multiple={multiple}
        allowDeselect={allowDeselect}
      >
        {opts =>
          opts.map(({ option, active, select }) => (
            <Button
              key={option.key}
              label={option.label}
              active={active}
              onClick={select}
              onKeyPress={select}
            />
          ))
        }
      </Selectable>
    </span>
  );
};

ButtonGroup.propTypes = {
  options: PropTypes.object.isRequired,
  onSelect: PropTypes.func.isRequired,
  activeOption: PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.arrayOf(PropTypes.string)
  ]).isRequired,
  multiple: PropTypes.bool,
  label: PropTypes.string,
  allowDeselect: PropTypes.bool
};

ButtonGroup.defaultProps = {
  multiple: false,
  label: undefined,
  allowDeselect: false
};

export default ButtonGroup;
