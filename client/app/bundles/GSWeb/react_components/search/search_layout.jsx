import React from 'react';
import PropTypes from 'prop-types';

const SearchLayout = ({
  renderHeader,
  renderRightRail,
  renderList,
  renderMap
}) => (
  <div className="search-component">
    {renderHeader()}
    <div className="right-rail">{renderRightRail()}</div>
    <div className="list-and-map">
      {renderList()}
      {renderMap()}
    </div>
  </div>
);

SearchLayout.propTypes = {
  renderHeader: PropTypes.func.isRequired,
  renderRightRail: PropTypes.func.isRequired,
  renderList: PropTypes.func.isRequired,
  renderMap: PropTypes.func.isRequired
};

export default SearchLayout;
