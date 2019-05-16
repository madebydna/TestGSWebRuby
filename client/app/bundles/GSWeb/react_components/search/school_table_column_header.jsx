import React from 'react';
import PropTypes from 'prop-types';
import ModalTooltip from 'react_components/modal_tooltip';
import { t, capitalize } from "util/i18n";

const SchoolTableColumnHeader = ({ colName, tooltipContent, classNameTH, footerNote, onSortChanged, sortField, activeSort, sortable }) => {
  if (sortable) {
    classNameTH += " sortable";
  }

  if (activeSort && (activeSort === sortField)) {
    classNameTH += " active-sort";
  }

  const _onSortChanged = sortField => {
    if (sortable) {
      return onSortChanged(sortField);
    }
  }

  return (
    <th className={`${classNameTH} table-headers`} value={t(colName)} onClick={() => _onSortChanged(sortField)}>
      {t(colName)} {sortable && <span className="icon-caret-down"/>}
      {tooltipContent &&
      <ModalTooltip content={tooltipContent}>
        <span className="info-circle icon-info" />
      </ModalTooltip>}
      {footerNote && <div className="footer-note">{footerNote}</div>}
    </th>
  );
};

SchoolTableColumnHeader.propTypes = {
  colName: PropTypes.string.isRequired,
  tooltipContent: PropTypes.string,
  classNameTH: PropTypes.string
};

export default SchoolTableColumnHeader;
