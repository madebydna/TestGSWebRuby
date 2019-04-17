import React from 'react';
import PropTypes from 'prop-types';
import { SM, size as viewportSize } from 'util/viewport';
import ButtonGroup from 'react_components/buttongroup';
import Select from '../select';

// composes Select list with ButtonGroup, choosing one based on width of viewport
const TableTabs = ({ options, activeOption, onChange }) => {
  if (viewportSize() > SM) {
    return (
      <div className="table-view-filter">
        <ButtonGroup
          options={options}
          activeOption={
            options.map(o => o.key).includes(activeOption)
              ? activeOption
              : options[0].key
          }
          onSelect={onChange}
        />
      </div>
    );
  }
  return (
    <Select
      objects={options}
      labelFunc={d => d.label}
      keyFunc={d => d.key}
      onChange={d => onChange(d.key)}
      defaultLabel={
        (options.find(obj => obj.key === activeOption) || options[0]).label
      }
      defaultValue={activeOption}
    />
  );
};

TableTabs.propTypes = {
  activeOption: PropTypes.string,
  onChange: PropTypes.func,
  options: PropTypes.arrayOf(
    PropTypes.shape({
      key: PropTypes.string,
      label: PropTypes.string
    })
  ).isRequired
};

TableTabs.defaultProps = {
  activeOption: null,
  onChange: () => {}
};

export default TableTabs;
