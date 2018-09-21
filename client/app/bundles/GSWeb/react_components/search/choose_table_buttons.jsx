import React from 'react';
import ButtonGroup from 'react_components/buttongroup';
import { t } from 'util/i18n';
import ChooseTableContext from './choose_table_context';
import { SM, validSizes } from 'util/viewport';
import Select from '../select';

const optionsArray = [
    {   key: 'Overview',
        label: t('Overview')
    },
    {   key: 'Academic',
        label: t('Ratings Snapshot')
    },
    {   key: 'Equity',
        label: t('Equity Test Scores')
    }
];

const optionsObject = {
    Overview: t('Overview'),
    Academic: t('Ratings Snapshot'),
    Equity: t('Equity Test Scores')
};


const ChooseTableButtons = () => (
    <ChooseTableContext.Consumer>
      {({ tableView, updateTableView, size, equitySize }) => {
        // Remove Equity from displaying in the selections
        if(equitySize === 0){
            delete optionsObject.Equity;
            optionsArray.splice(-1,1);
        }
        return(
            renderTableButtonsFilters(tableView, updateTableView, size)
        )
      }}
    </ChooseTableContext.Consumer>
);

const renderTableButtonsFilters = (tableView, updateTableView, size) => {
    if(size > SM){
        return(
            <ButtonGroup
                options={optionsObject}
                activeOption={tableView}
                onSelect={updateTableView}
            />
        )
    }else{
        return(
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

export default ChooseTableButtons;
