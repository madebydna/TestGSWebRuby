import React from 'react';
import PropTypes from 'prop-types';
import ButtonGroup from 'react_components/buttongroup';
import { validSizes, SM } from 'util/viewport';
import { t } from 'util/i18n';

const mobileOptions = [
  { key: 'list', label: <span className="icon-list" /> },
  { key: 'map', label: <span className="icon-location" /> },
  { key: 'table', label: <span className="icon-grid" /> }
];

const desktopOptions = [
  {
    key: 'list',
    label: (
      <span>
        <span className="icon-map" />
        <span style={{ marginLeft: '8px' }} />
        {t('ListMap view')}
      </span>
    )
  },
  {
    key: 'table',
    label: (
      <span>
        <span className="icon-grid" />
        <span style={{ marginLeft: '8px' }} />
        {t('Table view')}
      </span>
    )
  }
];

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
    (mobileOptions.map(o => o.key)).concat(desktopOptions.map(o => o.key))
  ).isRequired,
  onSelect: PropTypes.func.isRequired,
  size: PropTypes.oneOf(validSizes).isRequired
};
