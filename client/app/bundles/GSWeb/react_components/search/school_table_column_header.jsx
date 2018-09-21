import React from 'react';
import PropTypes from 'prop-types';
import ModalTooltip from 'react_components/modal_tooltip';
import { t, capitalize } from "util/i18n";

const SchoolTableColumnHeader = ({ colName, tooltipContent, classNameTH, tableView }) => (
  <th className={`${classNameTH} table-headers`}>
    {colName}
    {tooltipContent !== '' ? 
    <ModalTooltip content={tooltipContent}>
      <span className="info-circle icon-info" />
    </ModalTooltip> : null}
  </th>
);

SchoolTableColumnHeader.propTypes = {
  colName: PropTypes.string.isRequired,
  tooltipContent: PropTypes.string,
  classNameTH: PropTypes.string
};

export default SchoolTableColumnHeader;
