import React from 'react';
import MultiItemSelectable from 'react_components/multi_item_selectable';
import GradeLevelContext from './grade_level_context';

const options = { e: 'Elementary', m: 'Middle', h: 'High', p: 'Preschool' };

const GradeLevelFilter = () => (
  <GradeLevelContext.Consumer>
    {({ levelCodes, onLevelCodesChanged }) => (
      <React.Fragment>
        <span className="button-group hidden-xs">
          <MultiItemSelectable
            options={options}
            activeOptions={levelCodes}
            onSelect={onLevelCodesChanged}
          >
            {(key, label, active) => (
              <label key={key} className={active ? 'active' : ''}>
                {label}
              </label>
            )}
          </MultiItemSelectable>
        </span>
        <span className="button-group visible-xs">
          <MultiItemSelectable
            options={options}
            activeOptions={levelCodes}
            onSelect={onLevelCodesChanged}
          >
            {(key, label, active) => (
              <div>
                <input type="checkbox" key={key} checked={active} value={key} />
                <label>{label}</label>
              </div>
            )}
          </MultiItemSelectable>
        </span>
      </React.Fragment>
    )}
  </GradeLevelContext.Consumer>
);

export default GradeLevelFilter;
