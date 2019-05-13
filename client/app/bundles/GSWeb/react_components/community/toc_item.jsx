import React from 'react';
import PropTypes from 'prop-types';
import { t } from 'util/i18n';
import { capitalize } from 'util/i18n';

const TocItem = ({id, label, link, selected, anchor, handleClick}) => {
  return (
    <li onClick={() => handleClick(anchor)} className={selected ? 'selected' : ''}><div>{label}</div></li>
  )
}

export default TocItem;