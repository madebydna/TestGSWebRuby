import React from 'react';
import PropTypes from 'prop-types';
import { t } from 'util/i18n';
import { capitalize } from 'util/i18n';

const TocItem = ({id, label, link, selected, handleClick}) => {
  return (
    <li onClick={() => handleClick(id)} className={selected ? 'selected' : ''}><div>{label}</div></li>
  )
}

export default TocItem;