import React from 'react';
import CheckboxGroup from 'react_components/checkbox_group';
import GradeLevelContext from './grade_level_context';
import { t } from 'util/i18n';

const options = {
  p: t('PreK'),
  e: t('Elementary'),
  m: t('Middle'),
  h: t('High')
};

const GradeLevelCheckboxes = () => (
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

export default GradeLevelCheckboxes;
