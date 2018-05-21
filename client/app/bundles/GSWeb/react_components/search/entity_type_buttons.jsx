import React from 'react';
import LabeledButtonGroup from 'react_components/labeled_button_group';
import EntityTypeContext from './entity_type_context';

const options = {
  public: 'Public',
  charter: 'Charter',
  private: 'Private'
};

const EntityTypeButtons = () => (
  <EntityTypeContext.Consumer>
    {({ entityTypes, onEntityTypesChanged }) => (
      <LabeledButtonGroup
        multiple
        label="Filter by:"
        options={options}
        activeOption={entityTypes}
        onSelect={onEntityTypesChanged}
      />
    )}
  </EntityTypeContext.Consumer>
);

export default EntityTypeButtons;
