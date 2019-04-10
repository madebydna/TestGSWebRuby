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
  // default value to key if value not in an option
  const newOpts = options.map(o => ({value:o.key, ...o}))

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
              aria-label={option.key}
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
  options: PropTypes.arrayOf(PropTypes.object).isRequired,
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