import React from 'react';
import PropTypes from 'prop-types';

const BasicDataModuleDrawerRow = ({ label, children }) => {
  return (
    <div className="row bar-graph-display">
      <div className="test-score-container clearfix">
        <div className="col-xs-12 col-sm-4 subject">
          <span>
            {label}
          </span>
        </div>
        <div className="col-xs-12 col-sm-6">
          {children}
        </div>
        <div className="col-sm-2"></div>
      </div>
    </div>
  );
};

BasicDataModuleDrawerRow.propTypes = {
  label: PropTypes.element.isRequired,
  children: PropTypes.element.isRequired
}

export default BasicDataModuleDrawerRow;
