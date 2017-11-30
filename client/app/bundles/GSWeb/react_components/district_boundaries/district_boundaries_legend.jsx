import React, { PropTypes } from 'react';

export default ({legendContainerForCtaId, ...rest}) => (
  <div {...rest}>
    <div id={legendContainerForCtaId} style={{display: 'none'}}></div>
    <ul className="legend">
      <li><span/>District</li>
      <li><span/>Private school</li>
      <li><span/>Public school</li>
      <li><span/>Not rated school</li>
      <li><span/>School boundary</li>
      <li><span/>District boundary</li>
    </ul>
    <div className="attribution">School Boundaries © Maponics {(new Date()).getFullYear()}. Duplication is strictly prohibited.</div>
  </div>
);
