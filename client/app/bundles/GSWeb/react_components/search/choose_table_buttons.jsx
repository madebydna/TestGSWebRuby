import React from 'react';
import ButtonGroup from 'react_components/buttongroup';
import { t } from 'util/i18n';
import ChooseTableContext from './choose_table_context';
import { SM, validSizes } from 'util/viewport';
import TableSelect from './table_select';

const options = {
  Overview: t('School Overview'),
  Academic: t('Academic and Equity ratings'),
  Equity: t('Equity Test Score ratings')
};


const ChooseTableButtons = () => (
    <ChooseTableContext.Consumer>
      {({ tableView, updateTableView, size }) => (
        renderTableButtonsFilters(tableView, updateTableView, size)
      )}
    </ChooseTableContext.Consumer>
);

const renderTableButtonsFilters = (tableView, updateTableView, size) => {
    if(size > SM){
        return(
            <ButtonGroup
                options={options}
                activeOption={tableView}
                onSelect={updateTableView}
            />
        )
    }else{
        return(
            <TableSelect/>
        )
    }
};

export default ChooseTableButtons;
