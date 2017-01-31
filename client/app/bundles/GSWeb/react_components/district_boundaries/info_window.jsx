import React, { PropTypes } from 'react';
import jsxToString from 'jsx-to-string';

export default function createInfoWindow(entity) {

  let homesForSaleHref;
  if (entity.state && entity.address && entity.address.zip) {
    homesForSaleHref = 'https://www.zillow.com/' + entity.state + '-' + entity.address.zip.split("-")[0] + '?cbpartner=Great+Schools&utm_source=GreatSchools&utm_medium=referral&utm_campaign=districtbrowsemap';
  } else {
    homesForSaleHref = 'https://www.zillow.com/?cbpartner=Great+Schools&utm_source=GreatSchools&utm_medium=referral&utm_campaign=districtbrowsemap';
  }

  let schoolLevels = entity => {
    let levelNameMap = {p: 'Preschool', e: 'Elementary', m: 'Middle', h: 'High'};
    return Object.entries(entity.schoolCountsByLevelCode)
      .map(([level, value]) => [levelNameMap[level], value] );
  }

  let levelMarkup = entity => {
    return schoolLevels(entity).map(([level, value]) => '<span>' + level + ' (' + value + ')</span>').join(', ')
  };

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
      { entity.schoolCountsByLevelCode && <div>{levelMarkup(entity)}</div> }

      <a href={homesForSaleHref} rel="nofollow">Homes for sale</a>
      { entity.links && entity.links.profile &&
        <a href={entity.links.profile}>View school details</a>
      }
    </div>
  );
  return jsxToString(contentString);
}
