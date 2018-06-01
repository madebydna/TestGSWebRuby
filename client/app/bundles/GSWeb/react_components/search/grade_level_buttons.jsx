import React from 'react';
import ButtonGroup from 'react_components/buttongroup';
import GradeLevelContext from './grade_level_context';

const options = {
  e: 'Elementary',
  m: 'Middle',
  h: 'High',
  p: 'Preschool'
};

const GradeLevelFilter = () => (
  <GradeLevelContext.Consumer>
    {({ levelCodes, onLevelCodesChanged }) => (
      <ButtonGroup
        multiple
        allowDeselect
        options={options}
        activeOption={levelCodes}
        onSelect={onLevelCodesChanged}
      />
    )}
  </GradeLevelContext.Consumer>
);

export default GradeLevelFilter;
