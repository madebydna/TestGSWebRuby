import React from 'react';
import ButtonGroup from 'react_components/buttongroup';
import MultiItemSelectable from 'react_components/multi_item_selectable';
import EntityTypeContext from './entity_type_context';

const options = {public: 'Public', charter: 'Charter', private: 'Private'}

const EntityTypeFilter = ({className='entity-type-filter', label='Type', ...otherLinkAttributes}) => {
  return (
    <EntityTypeContext.Consumer>
      {({school_types, onEntityTypesChanged}) => (
        <React.Fragment>
          <span className='button-group hidden-xs'>
            <MultiItemSelectable options={options} activeOptions={school_types}
              onSelect={onEntityTypesChanged}>
              {
                (key, label, active) =>
                  <label key={key} className={active ? 'active' : ''}>
                    {label}
                  </label>
              }
            </MultiItemSelectable>
          </span>
          <span className='button-group visible-xs'>
            <MultiItemSelectable options={options} activeOptions={school_types}
              onSelect={onEntityTypesChanged}>
              {
                (key, label, active) => <div>
                  <input type="checkbox" key={key} checked={active} value={key} />
                  <label>{label}</label>
                </div>
              }
            </MultiItemSelectable>
          </span>
        </React.Fragment>
      )}
    </EntityTypeContext.Consumer>
  )
};

export default EntityTypeFilter;

