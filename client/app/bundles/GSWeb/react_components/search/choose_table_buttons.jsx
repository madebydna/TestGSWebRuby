import React from 'react';
import ButtonGroup from 'react_components/buttongroup';
import { t } from 'util/i18n';
import ChooseTableContext from './choose_table_context';
import { SM, validSizes } from 'util/viewport';
import Select from '../select';
import PropTypes from 'prop-types';

const optionsArray = [
    {
        key: 'Overview',
        label: t('Overview')
    },
    {
        key: 'Academic',
        label: t('Ratings Snapshot')
    },
    {
        key: 'Equity',
        label: t('Equity Test Scores')
    }
];

const optionsObject = createObjFromArray(optionsArray);

function createObjFromArray(array) {
    return array.reduce((obj, tabView) => {
        obj[tabView.key] = tabView.label
        return obj
    }, {})
}


const ChooseTableButtons = () => (
    <ChooseTableContext.Consumer>
        {({ tableView, updateTableView, size, equitySize }) => {
            // Remove Equity from displaying in the selections
            if (equitySize === 0 && optionsObject.Equity) {
                delete optionsObject.Equity;
                optionsArray.splice(-1, 1);
            }
            return (
                renderTableButtonsFilters(tableView, updateTableView, size)
            )
        }}
    </ChooseTableContext.Consumer>
);

const renderTableButtonsFilters = (tableView, updateTableView, size) => {
    if (size > SM) {
        return (
            <div className="table-view-filter">
                <ButtonGroup
                    options={optionsObject}
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
    searchTableViewHeaders: PropTypes.object,
    tableView: PropTypes.string
};

ChooseTableButtons.defaultProps = {
    searchTableViewHeaders: {},
    tableView: 'Overview'
};

export default ChooseTableButtons;
