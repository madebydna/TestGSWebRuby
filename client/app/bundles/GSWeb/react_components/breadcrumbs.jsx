import React from 'react';
import PropTypes from 'prop-types';

const Breadcrumbs = ({ items }) => (
  items.length > 0 &&
  <div className="breadcrumbs">
    {items
      .map(({ url, text }) => <a href={url}>{text}</a>)
      .reduce((list, current) => [
        list,
        <span className="icon-chevron-right separator" />,
        current
      ],[])}
  </div>
);

Breadcrumbs.propTypes = {
  items: PropTypes.arrayOf(
    PropTypes.shape({
      text: PropTypes.string.isRequired,
      url: PropTypes.string.isRequired
    })
  ).isRequired
};
export default Breadcrumbs;
