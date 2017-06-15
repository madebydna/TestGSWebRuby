import React from 'react';

// TODOs:
// - rename subject css class
// - rename bar-graph-container css class

const DataLabelAndVisualization = ({textValue, stateAverage, visualization}) => {
  return (
    <div className="row bar-graph-display">
      <div className="test-score-container clearfix">
        <div className="col-xs-12 col-sm-5 subject">{label}</div>
        <div className="col-sm-1"></div>
        <div className="col-xs-9 col-sm-4">
          <div className="bar-graph-container">
            <div className="score">{textValue}</div>
            {children}
          </div>
          { stateAverage && <div className="state-average">
              State avg: {stateAverage}
            </div>
          }
        </div>
        <div className="col-xs-3 col-sm-2">
        </div>
      </div>
    </div>
  );
};

DataLabelAndVisualization.PropTypes = {
}

export default ParentTip;
