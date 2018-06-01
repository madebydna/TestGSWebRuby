import React from 'react';
import Dropdown from './dropdown';

const options = [
  {
    key: 'list',
    label: (
      <span>
        <span className="icon-list" />
        <span style={{ marginLeft: '8px' }} />List view
      </span>
    )
  },
  {
    key: 'map',
    label: (
      <span>
        <span className="icon-question" />
        <span style={{ marginLeft: '8px' }} />Map view
      </span>
    )
  }
];

const ListMapDropdown = ({ currentView, onSelect } = {}) => (
  <div>
    <Dropdown
      onSelect={opt => onSelect(opt.key)}
      options={options}
      activeOption={options.find(o => o.key === currentView)}
    />
  </div>
);

export default ListMapDropdown;
