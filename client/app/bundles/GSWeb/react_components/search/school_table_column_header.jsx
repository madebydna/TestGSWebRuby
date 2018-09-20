import React from 'react';
import PropTypes from 'prop-types';
// import { t, capitalize } from "util/i18n";  may need this, maybe not

const SchoolTableColumnHeader = ({ colName, tooltipContent, classNameTH }) => (
  <th className={classNameTH}>{colName}</th>
);

SchoolTableColumnHeader.propTypes = {
  colName: PropTypes.string.isRequired,
  tooltipContent: PropTypes.string,
  classNameTH: PropTypes.string
};

export default SchoolTableColumnHeader;
