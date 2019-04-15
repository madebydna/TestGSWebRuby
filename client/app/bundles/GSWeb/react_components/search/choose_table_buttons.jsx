import React from 'react';
import PropTypes from 'prop-types';
import { SM } from 'util/viewport';
import ButtonGroup from 'react_components/buttongroup';
import ChooseTableContext from './choose_table_context';
import Select from '../select';

function createObjFromArray(array) {
  return array.reduce((obj, tabView) => {
    obj[tabView.key] = tabView.label;
    return obj;
  }, {});
}

const renderTableButtonsFilters = (
  tableView,
  updateTableView,
  size,
  options
) => {
  if (size > SM) {
    const optionsObject = createObjFromArray(options);
    return (
      <div className="table-view-filter">
        <ButtonGroup
          options={optionsObject}
          activeOption={
            Object.keys(optionsObject).includes(tableView)
              ? tableView
              : 'Overview'
          }
          onSelect={updateTableView}
        />
      </div>
    );
  }
  return (
    <Select
      objects={options}
      labelFunc={d => d.label}
      keyFunc={d => d.key}
      onChange={d => updateTableView(d.key)}
      defaultLabel={
        (options.find(obj => obj.key === tableView) || options[0]).label
      }
      defaultValue={tableView}
    />
  );
};

const ChooseTableButtons = ({ options }) => (
  <ChooseTableContext.Consumer>
    {({ tableView, updateTableView, size, equitySize }) => {
      
      const optionsObject = createObjFromArray(options);
      // Remove Equity from displaying in the selections
      if (equitySize === 0 && optionsObject.Equity) {
        delete optionsObject.Equity;
        // options = [...options].splice(-1, 1);
      }
      return renderTableButtonsFilters(
        tableView,
        updateTableView,
        size,
        options
      );
    }}
  </ChooseTableContext.Consumer>
);

const renderTableButtonsFilters = (tableView, updateTableView, size) => {
    if (size > SM) {
        return (
            <div className="table-view-filter">
                <ButtonGroup
                    options={optionsArray}
                    activeOption={
                        Object.keys(optionsObject).includes(tableView) ? tableView : "Overview"
                    }
                    onSelect={updateTableView}
                />
            </div>
        )
    } else {
        return (
            <ChooseTableContext.Consumer>
                {({ tableView, updateTableView }) => (
                    <Select
                        objects={optionsArray}
                        labelFunc={d => d.label}
                        keyFunc={d => d.key}
                        onChange={d => updateTableView(d.key)}
                        defaultLabel={
                            (optionsArray.find(obj => obj.key === tableView) || optionsArray[0]).label
                        }
                        defaultValue={tableView}
                    />
                )}
            </ChooseTableContext.Consumer>
        )
    }
};
ChooseTableButtons.propTypes = {
  options: PropTypes.arrayOf(
    PropTypes.shape({
      key: PropTypes.string,
      label: PropTypes.string
    })
  ).isRequired
};

ChooseTableButtons.defaultProps = {};

export default ChooseTableButtons;
