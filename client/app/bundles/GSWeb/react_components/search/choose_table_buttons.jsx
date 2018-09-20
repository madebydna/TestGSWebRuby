import React from 'react';
import ButtonGroup from 'react_components/buttongroup';
import { t } from 'util/i18n';
import ChooseTableContext from './choose_table_context';

const options = {
  Overview: t('School Overview'),
  Academic: t('Academic and Equity ratings'),
  Equity: t('Equity Test Score ratings')
};


const ChooseTableButtons = () => (
    <ChooseTableContext.Consumer>
      {({ tableView, updateTableView }) => (
          <ButtonGroup
              options={options}
              activeOption={tableView}
              onSelect={updateTableView}
          />
      )}
    </ChooseTableContext.Consumer>
);

export default ChooseTableButtons;
