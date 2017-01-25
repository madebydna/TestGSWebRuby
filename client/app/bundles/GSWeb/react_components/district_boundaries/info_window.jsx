import React, { PropTypes } from 'react';
import jsxToString from 'jsx-to-string';

export default function createInfoWindow(entity) {

  // let homesForSaleHref;
  // if (typeof entity.state && entity.address && entity.address.zip) {
  //   homesForSaleHref = 'https://www.zillow.com/' + state + '-' + zip.split("-")[0] + '?cbpartner=Great+Schools&utm_source=Great_Schools&utm_medium=referral&utm_campaign=schoolsearch';
  // } else {
  //   homesForSaleHref = 'https://www.zillow.com/?cbpartner=Great+Schools&utm_source=Great_Schools&utm_medium=referral&utm_campaign=schoolsearch';
  // }

  let contentString = (
    <div class="infowindow" style="padding:10px">
      <div class="clearfix">
        { entity.rating != 'NR' &&
          <div class={'circle-rating--' + entity.rating + ' circle-rating--medium rating'} style="float:left; margin-right: 20px">
            {entity.rating}<span class="rating-circle-small">/10</span>
          </div>
        }
        <div style="float:left;">
          <div>
            <span class="title">
              <a href={entity.show}>{entity.name}</a>
            </span>
          </div>
          {entity.address &&
            <div>
              <div>{entity.address.street1}</div>
              <div>{entity.address.city + ','} {entity.state} {entity.address.zip}</div>
            </div>
          }
        </div>
      </div>
      <hr/>
      <a href="" rel="nofollow">Homes for sale</a>
      <a href="">View school details</a>
    </div>
  );
  return jsxToString(contentString);
}
