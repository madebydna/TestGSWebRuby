import React from 'react';
import PropTypes from 'prop-types';

const Select = ({objects, keyFunc, labelFunc, onChange, defaultValue, defaultLabel}) => {
  const options = () => {
    if(objects.length > 0) {
      return objects.map(obj => {
        let key = keyFunc(obj);
        return <option key={keyFunc(obj)} value={keyFunc(obj)}>{labelFunc(obj)}</option>
      });
    } else {
     return <option value=''>{defaultLabel}</option>;
    }
  }

  const _onChange = event => 
    onChange(objects.find(obj=> keyFunc(obj) == event.target.value));

  return <select key={defaultLabel} onChange={_onChange} defaultValue={defaultValue}>{options()}</select>;
};

Select.propTypes = {
  objects: PropTypes.array.isRequired,
  keyFunc: PropTypes.func.isRequired,
  labelFunc: PropTypes.func.isRequired,
  onChange: PropTypes.func,
  defaultValue: PropTypes.any
}

export default Select;
