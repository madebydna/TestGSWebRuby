import React from 'react';
import Selectable from 'react_components/selectable';
import EntityTypeContext from './entity_type_context';
import LabelButton from './label_button';

const options = [
  { key: 'public', label: 'Public' },
  { key: 'charter', label: 'Charter' },
  { key: 'private', label: 'Private' }
];

const EntityTypeFilter = () => (
  <EntityTypeContext.Consumer>
    {({ entityTypes, onEntityTypesChanged }) => (
      <Selectable
        multiple
        options={options}
        activeOptions={entityTypes}
        onSelect={onEntityTypesChanged}
        keyFunc={o => o.key}
      >
        {opts => (
          <React.Fragment>
            <span className="button-group hidden-xs">
              {opts.map(({ select, active, option } = {}) => (
                <LabelButton
                  key={option.key}
                  label={option.label}
                  active={active}
                  onClick={select}
                  onKeyPress={select}
                />
              ))}
            </span>
            <span className="button-group visible-xs">
              {opts.map(({ select, active, option } = {}) => (
                <div onClick={select} onKeyPress={select} role="button">
                  <input
                    type="checkbox"
                    key={option.key}
                    defaultChecked={active}
                    value={option.key}
                  />
                  <label>{option.label}</label>
                </div>
              ))}
            </span>
          </React.Fragment>
        )}
      </Selectable>
    )}
  </EntityTypeContext.Consumer>
);

export default EntityTypeFilter;
