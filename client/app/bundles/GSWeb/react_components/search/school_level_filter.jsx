import React from 'react';
import ButtonGroup from 'react_components/buttongroup';
import MultiItemSelectable from 'react_components/multi_item_selectable';

const SchoolLevelFilter = ({handler, level=null,  className='grade-filter', label='School Grade', ...otherLinkAttributes}) => {
  return (
    <MultiItemSelectable options={{e: 'Elementary', m: 'Middle', h: 'High', p: 'Preschool'}}
      onSelect={(sel) => {console.log(sel)}}
      className='button-group'>
      {
        (key, label, active) =>
        <label key={key} className={active ? 'active' : ''}>
          {label}
        </label>
      }
    </MultiItemSelectable>
  )
};

export default SchoolLevelFilter;

