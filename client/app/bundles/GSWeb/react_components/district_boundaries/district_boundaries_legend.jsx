import React, { PropTypes } from 'react';

export default ({legendContainerForCtaId}) => (
  <div>
    <div id={legendContainerForCtaId} style={{display: 'none'}}></div>
    <ul className="legend">
      <li><span/>District</li>
      <li><span/>Private school</li>
      <li><span/>Public school</li>
      <li><span/>Not rated school</li>
      <li><span/>School boundary</li>
      <li><span/>District boundary</li>
    </ul>
  </div>
);
