import React from 'react';
import PropTypes from 'prop-types';
import Selectable from './selectable';
import OpenableCloseable from './openable_closeable';

const Dropdownable = ({ options, activeOption, onSelect, children } = {}) => (
  <OpenableCloseable>
    {(isOpen, { toggle, open, close } = {}) => (
      <Selectable
        onSelect={onSelect}
        allowDeselect={false}
        options={options}
        activeOptions={[activeOption]}
      >
        {opts =>
          children({
            isOpen,
            toggle,
            open,
            close,
            selection: (opts.find(o => o.active === true) || {}).option,
            options: opts.map(o => ({
              ...o,
              select: () => {
                o.select();
                close();
              }
            }))
          })
        }
      </Selectable>
    )}
  </OpenableCloseable>
);

Dropdownable.propTypes = {
  options: PropTypes.arrayOf(PropTypes.object).isRequired,
  activeOption: PropTypes.object,
  onSelect: PropTypes.func.isRequired,
  children: PropTypes.func.isRequired
};

Dropdownable.defaultProps = {
  activeOption: {}
};

export default Dropdownable;
