import React from 'react';
import Selectable from 'react_components/selectable';
import GradeLevelContext from './grade_level_context';
import LabelButton from './label_button';

const options = [
  { key: 'e', label: 'Elementary' },
  { key: 'm', label: 'Middle' },
  { key: 'h', label: 'High' },
  { key: 'p', label: 'Preschool' }
];

const GradeLevelFilter = () => (
  <GradeLevelContext.Consumer>
    {({ levelCodes, onLevelCodesChanged }) => (
      <Selectable
        multiple
        options={options}
        activeOptions={levelCodes}
        onSelect={onLevelCodesChanged}
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
  </GradeLevelContext.Consumer>
);

export default GradeLevelFilter;
