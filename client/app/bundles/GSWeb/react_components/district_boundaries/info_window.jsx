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

  let ratingDiv = (entity) => {
    let visibleRating = entity.rating != 'NR' ? entity.rating : undefined;
    let ratingText = <span></span>;

    if(visibleRating) {
      ratingText = (<div>{visibleRating}<span>/10</span></div>);
    }
    let shape = 'circle';
    if(entity.type == 'school' && entity.schoolType == 'private') {
      shape = 'diamond';
    } else if (entity.type == 'district') {
      shape = 'square';
    }
    return (
      <div class={'rating_' + entity.rating + ' ' + shape +'-rating--small rating'}>{ratingText}</div>
    );
  };

  let contentString = (
    <div class="info-window">
      <div class="clearfix">
        { jsxToString(ratingDiv(entity)).replace(/>\s+/, '>').replace(/\s+</, '<') }
        <div class="school-info">
          <a href={entity.links.profile}>{entity.name}</a>
          {entity.type == 'school' && entity.address &&
            <div>
              <div>{entity.address.street1}</div>
              <div>{entity.address.city + ','} {entity.state} {entity.address.zip}</div>
            </div>
          }
          { entity.schoolCountsByLevelCode && <div><br/>Number of schools:<div>{levelMarkup(entity)}</div></div> }
        </div>
      </div>
      <hr/>
      <div class="other-links">
        <span class="icon-house">  </span>
        <a href={homesForSaleHref} rel="nofollow">Homes for sale</a>
        { entity.links && entity.links.profile &&
          <a href={entity.links.profile} class="school-details">View school details</a>
        }
      </div>
    </div>
  );
  return jsxToString(contentString);
}
