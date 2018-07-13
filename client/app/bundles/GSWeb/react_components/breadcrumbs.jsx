import React from 'react';
import PropTypes from 'prop-types';

const joinWithSeparator = (arrayOfElements, separator) =>
  arrayOfElements
    .filter(e => !!e)
    .reduce((list, current) => [list, separator, current]);

const Breadcrumbs = ({ items }) =>
  items.length > 0 && (
    <div className="breadcrumbs">
      {joinWithSeparator(
        items.map(({ url, text }) => (
          <a key={url + text} href={url}>
            {text}
          </a>
        )),
        <span key={1} className="icon-chevron-right divider" />
      )}
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
