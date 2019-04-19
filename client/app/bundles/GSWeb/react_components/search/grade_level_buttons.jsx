import React from 'react';
import ButtonGroup from 'react_components/buttongroup';
import GradeLevelContext from './grade_level_context';
import { t } from 'util/i18n';

const options = [
  { key: 'p', label: t('PreK') },
  { key: 'e', label: t('Elementary') },
  { key: 'm', label: t('Middle') },
  { key: 'h', label: t('High') },
]

const GradeLevelButtons = () => (
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

export default GradeLevelButtons;
