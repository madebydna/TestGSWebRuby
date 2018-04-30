import React from 'react';
import ButtonGroup from 'react_components/buttongroup';
import MultiItemSelectable from 'react_components/multi_item_selectable';
import GradeLevelContext from './grade_level_context';

const options = {e: 'Elementary', m: 'Middle', h: 'High', p: 'Preschool'}

const GradeLevelFilter = ({className='grade-filter', label='Grade level', ...otherLinkAttributes}) => {
  return (
    <GradeLevelContext.Consumer>
      {({level_codes, onLevelCodesChanged}) => (
        <React.Fragment>
          <span className='button-group hidden-xs'>
            <MultiItemSelectable options={options} activeOptions={level_codes}
              onSelect={onLevelCodesChanged}>
              {
                (key, label, active) =>
                  <label key={key} className={active ? 'active' : ''}>
                    {label}
                  </label>
              }
            </MultiItemSelectable>
          </span>
          <span className='button-group visible-xs'>
            <MultiItemSelectable options={options} activeOptions={level_codes}
              onSelect={onLevelCodesChanged}>
              {
                (key, label, active) => <div>
                  <input type="checkbox" key={key} checked={active} value={key} />
                  <label>{label}</label>
                </div>
              }
            </MultiItemSelectable>
          </span>
        </React.Fragment>
      )}
    </GradeLevelContext.Consumer>
  )
};

export default GradeLevelFilter;

