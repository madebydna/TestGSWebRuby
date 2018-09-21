import React from 'react';
import PropTypes from 'prop-types';
import Select from '../select';
import ChooseTableContext from './choose_table_context';
import { t } from 'util/i18n';

const defaultOptions = [
  {
    key: 'Overview',
    label: t('School Overview')
  },
  {
    key: 'Academic',
    label: t('Academic and Equity ratings')
  },
  {
    key: 'Equity',
    label: t('Equity Test Score ratings')
  }
];

const TableSelect = () => {
  let options = defaultOptions;

  return(
    <ChooseTableContext.Consumer>
      {({tableView, updateTableView})=>(
        <Select
          objects={defaultOptions}
          labelFunc={d => d.label}
          keyFunc={d => d.key}
          onChange={d => updateTableView(d.key)}
          defaultLabel={
            (options.find(obj => obj.key === tableView) || options[0]).label
          }
          defaultValue={tableView}
        />
      )}
    </ChooseTableContext.Consumer>
  );
}

export default TableSelect;