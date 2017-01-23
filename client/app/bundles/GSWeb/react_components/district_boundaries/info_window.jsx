import React, { PropTypes } from 'react';
import jsxToString from 'jsx-to-string';

export default function createInfoWindow(entity) {
  let contentString = (<div class="rating-container__rating">
    <div class="module-header">
      <div class={'circle-rating--' + entity.rating + ' circle-rating--medium'}>
        {entity.rating}<span class="rating-circle-small">/10</span>
      </div>
      <div class="title-container" style="width:300px">
        <div>
          <span class="title">
            {entity.name}
          </span>
        </div>
        {entity.address &&
          <div>
            <div>{entity.address.street1}</div>
            <div>{entity.address.city}, {entity.address.state} {entity.address.zip}</div>
          </div>
        }
      </div>
    </div>
  </div>);
  return jsxToString(contentString);
}
