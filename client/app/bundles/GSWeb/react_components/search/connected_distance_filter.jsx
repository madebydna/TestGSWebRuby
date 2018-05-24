import React from 'react';
import DistanceContext from './distance_context';
import DistanceFilter from './distance_filter';

// https://reactjs.org/docs/context.html#examples
const ConnectedDistanceFilter = props => (
  <DistanceContext.Consumer>
    {({ distance, onChange }) => (
      <DistanceFilter {...props} distance={distance} onChange={onChange} />
    )}
  </DistanceContext.Consumer>
);

export default ConnectedDistanceFilter;
