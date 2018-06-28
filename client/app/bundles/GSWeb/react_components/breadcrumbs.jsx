import React from 'react';
import PropTypes from 'prop-types';

const Breadcrumbs = ({ items }) => (
  <div className="breadcrumbs">
    {items
      .map(breadcrumb => <a href={breadcrumb[1]}>{breadcrumb[0]}</a>)
      .reduce((prev, curr) => [
        prev,
        <span className="icon-chevron-right separator" />,
        curr
      ])}
  </div>
);
Breadcrumbs.propTypes = {
  items: PropTypes.arrayOf(PropTypes.arrayOf(PropTypes.string)).isRequired
};
export default Breadcrumbs;
