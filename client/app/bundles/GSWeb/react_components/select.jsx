import React from 'react';

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

  return <select onChange={_onChange} defaultValue={defaultValue}>{options()}</select>;
};

Select.PropTypes = {
  objects: React.PropTypes.array.isRequired,
  keyFunc: React.PropTypes.func.isRequired,
  labelFunc: React.PropTypes.func.isRequired,
  onChange: React.PropTypes.func,
  defaultValue: React.PropTypes.any
}

export default Select;
