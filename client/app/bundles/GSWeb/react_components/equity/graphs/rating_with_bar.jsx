import React from 'react';
import Rating from 'components/rating';
import SingleBarViz from './single_bar_viz';

const RatingWithBar = ({score, size, state_average}) => {
  return (
    <div className="rating-with-bar">
      <div className="rating">
        <Rating score={score} size={size} />
      </div>
      <div className="bar">
        <SingleBarViz score={score*10} />
      </div>
    </div>
  );
};

export default RatingWithBar;
