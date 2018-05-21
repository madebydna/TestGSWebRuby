import React from 'react';
import CheckboxGroup from 'react_components/checkbox_group';
import EntityTypeContext from './entity_type_context';

const options = {
  public: 'Public',
  charter: 'Charter',
  private: 'Private'
};

const EntityTypeButtons = () => (
  <EntityTypeContext.Consumer>
    {({ entityTypes, onEntityTypesChanged }) => (
      <React.Fragment>
        <span className="label">School type:</span>
        <CheckboxGroup
          multiple
          label="Filter by:"
          options={options}
          activeOption={entityTypes}
          onSelect={onEntityTypesChanged}
        />
      </React.Fragment>
    )}
  </EntityTypeContext.Consumer>
);

export default EntityTypeButtons;
