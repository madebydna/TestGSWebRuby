import React, { PropTypes } from 'react';
import Rating from './rating';
import SingleBarViz from './single_bar_viz';

const RatingWithBar = ({score, state_average}) => {
  return (
    <div className="rating-with-bar">
      <div className="rating">
        <Rating score={score} />
      </div>
      <div className="bar">
        <SingleBarViz score={score*10} />
      </div>
    </div>
  );
};

export default RatingWithBar;
