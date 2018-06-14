import React from 'react';
import CheckboxGroup from 'react_components/checkbox_group';
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
      <CheckboxGroup
        multiple
        options={options}
        activeOption={levelCodes}
        onSelect={onLevelCodesChanged}
      />
    )}
  </GradeLevelContext.Consumer>
);

export default GradeLevelFilter;
