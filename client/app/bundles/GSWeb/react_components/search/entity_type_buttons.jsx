import React from 'react';
import LabeledButtonGroup from 'react_components/labeled_button_group';
import EntityTypeContext from './entity_type_context';

const options = [
  { key: 'public', label: 'Public' },
  { key: 'charter', label: 'Charter' },
  { key: 'private', label: 'Private' },
]

const EntityTypeButtons = () => (
  <EntityTypeContext.Consumer>
    {({ entityTypes, onEntityTypesChanged }) => (
      <LabeledButtonGroup
        multiple
        allowDeselect
        label="Filter by:"
        options={options}
        activeOption={entityTypes}
        onSelect={onEntityTypesChanged}
      />
    )}
  </EntityTypeContext.Consumer>
);

export default EntityTypeButtons;
