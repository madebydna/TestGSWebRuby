import React from 'react';
import PropTypes from 'prop-types';
import ButtonGroup from 'react_components/buttongroup';
import { validSizes, SM } from 'util/viewport';
import { t } from 'util/i18n';

const mobileOptions = {
  list: <span className="icon-list" />,
  map: <span className="icon-location" />,
  table: <span className="icon-grid" />
};

const desktopOptions = {
  list: (
    <span>
      <span className="icon-map" />
      <span style={{ marginLeft: '8px' }} />
      {t('ListMap view')}
    </span>
  ),
  table: (
    <span>
      <span className="icon-grid" />
      <span style={{ marginLeft: '8px' }} />
      {t('Table view')}
    </span>
  )
};

const ListMapDropdown = ({ view, onSelect, size }) => {
  if (size > SM && view === 'map') {
    view = 'list';
  }
  return (
    <ButtonGroup
      onSelect={onSelect}
      options={size <= SM ? mobileOptions : desktopOptions}
      activeOption={view}
    />
  );
};

export default ListMapDropdown;

ListMapDropdown.propTypes = {
  view: PropTypes.oneOf(
    Object.keys(mobileOptions).concat(Object.keys(desktopOptions))
  ).isRequired,
  onSelect: PropTypes.func.isRequired,
  size: PropTypes.oneOf(validSizes).isRequired
};
