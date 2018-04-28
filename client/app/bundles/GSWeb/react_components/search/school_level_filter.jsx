import React from 'react';
import ButtonGroup from 'react_components/buttongroup';
import MultiItemSelectable from 'react_components/multi_item_selectable';

const options = {e: 'Elementary', m: 'Middle', h: 'High', p: 'Preschool'}

const SchoolLevelFilter = ({handler=null, level=null,  className='grade-filter', label='School Grade', ...otherLinkAttributes}) => {
  if(!handler) {
    handler = (sel) => console.log(sel)
  }
  return (
    <div>
      <MultiItemSelectable options={options} onSelect={handler} className='button-group hidden-xs'>
        {
          (key, label, active) =>
            <label key={key} className={active ? 'active' : ''}>
              {label}
            </label>
        }
      </MultiItemSelectable>
      <MultiItemSelectable options={options} onSelect={handler} className='button-group visible-xs'>
        {
          (key, label, active) => <div>
            <input type="checkbox" key={key} checked={active} value={key} />
            <label>{label}</label>
          </div>
        }
      </MultiItemSelectable>
    </div>
  )
};

export default SchoolLevelFilter;

