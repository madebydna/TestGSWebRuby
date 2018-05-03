import React from 'react';
import MultiItemSelectable from 'react_components/multi_item_selectable';
import EntityTypeContext from './entity_type_context';

const options = [
  { key: 'public', label: 'Public' },
  { key: 'charter', label: 'Charter' },
  { key: 'private', label: 'Private' }
];

const EntityTypeFilter = () => (
  <EntityTypeContext.Consumer>
    {({ entityTypes, onEntityTypesChanged }) => (
      <React.Fragment>
        <span className="button-group hidden-xs">
          <MultiItemSelectable
            options={options}
            activeKeys={entityTypes}
            onSelect={onEntityTypesChanged}
          >
            {({ key, label, active }) => (
              <label key={key} className={active ? 'active' : ''}>
                {label}
              </label>
            )}
          </MultiItemSelectable>
        </span>
        <span className="button-group visible-xs">
          <MultiItemSelectable
            options={options}
            activeKeys={entityTypes}
            onSelect={onEntityTypesChanged}
          >
            {({ key, label, active }) => (
              <div>
                <input
                  type="checkbox"
                  key={key}
                  defaultChecked={active}
                  value={key}
                />
                <label>{label}</label>
              </div>
            )}
          </MultiItemSelectable>
        </span>
      </React.Fragment>
    )}
  </EntityTypeContext.Consumer>
);

export default EntityTypeFilter;
