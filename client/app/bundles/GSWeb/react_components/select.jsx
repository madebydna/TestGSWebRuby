import React from 'react';

const Select = ({objects, keyFunc, labelFunc, onChange, value}) => {
  const options = () => objects.map(obj => {
    let key = keyFunc(obj);
    return <option key={keyFunc(obj)} value={keyFunc(obj)}>{labelFunc(obj)}</option>
  });

  const _onChange = event => 
    onChange(objects.find(obj=> keyFunc(obj) == event.target.value));

  return <select value={value} onChange={_onChange}>{options()}</select>;
};

Select.PropTypes = {
  objects: React.PropTypes.array.isRequired,
  keyFunc: React.PropTypes.func.isRequired,
  labelFunc: React.PropTypes.func.isRequired,
  onChange: React.PropTypes.func,
  value: React.PropTypes.string
}

export default Select;
