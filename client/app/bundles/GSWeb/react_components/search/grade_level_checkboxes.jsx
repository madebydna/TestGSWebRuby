import React from 'react';
import ButtonGroup from 'react_components/buttongroup';
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
      <React.Fragment>
        <span className="label">Grade level:</span>
        <CheckboxGroup
          multiple
          options={options}
          activeOption={levelCodes}
          onSelect={onLevelCodesChanged}
        />
      </React.Fragment>
    )}
  </GradeLevelContext.Consumer>
);

export default GradeLevelFilter;
