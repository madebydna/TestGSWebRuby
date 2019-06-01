import React from 'react';
import PropTypes from 'prop-types';
import ModalTooltip from 'react_components/modal_tooltip';
import { t, capitalize } from "util/i18n";

const SchoolTableColumnHeader = ({ colName, tooltipContent, classNameTH, footerNote, onSortChanged, sortField, activeSort, sortable }) => {
  let sortCaretIndicator = 'icon-caret-down rotate-text-270';
  if (sortable) {
    classNameTH += " sortable";
  }

  if (activeSort && (activeSort === sortField)) {
    classNameTH += " active-sort";
    sortCaretIndicator = 'icon-caret-down';
  }

  const _onSortChanged = sortField => {
    if (sortable) {
      return onSortChanged(sortField);
    }
  }

  return (
    <th className={`${classNameTH} table-headers`} value={t(colName)} onClick={() => _onSortChanged(sortField)}>
      {t(colName)} {sortable && <span className={sortCaretIndicator}/>}
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
  classNameTH: PropTypes.string,
  onSortChanged: PropTypes.func,
  sortField: PropTypes.string,
  activeSort: PropTypes.string,
  sortable: PropTypes.bool
};

export default SchoolTableColumnHeader;
