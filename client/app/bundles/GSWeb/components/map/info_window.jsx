import React from 'react';
import jsxToString from 'jsx-to-string';
import { capitalize, t } from 'util/i18n';

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
    let ratingScale = '';

    if(visibleRating) {
      ratingText = (<div>{visibleRating}<span>/10</span></div>);
      if (entity.ratingScale) {
        let scaleString = entity.ratingScale.split(' ').join('<br/>');
        ratingScale = (
            <div class="rating-scale">
              {scaleString}
            </div>);
      }
    }
    let shape = 'circle';
    if(entity.type == 'school' && entity.schoolType == 'private') {
      shape = 'diamond';
    } else if (entity.type == 'district') {
      shape = 'square';
    }
    if (entity.type == 'school') {
      return (
          <div class="rating-container">
            <div class={'rating_' + entity.rating + ' ' + shape + '-rating--small rating'}>{ratingText}</div>
            { ratingScale }
          </div>
      );
    } else {
      return (
        <div></div>
      );
    }
  };

  let addressString = `${entity.address.street1}, ${entity.address.city}, ${entity.state} ${entity.address.zip}`;
  let typeString = `${capitalize(entity.schoolType)}, ${entity.gradeLevels}`;
  let contentString = (
    <div class="info-window">
      {entity.assigned && <div class="assigned-text">{t('assigned')}</div>}
      <div class="clearfix">
        { jsxToString(ratingDiv(entity)).replace(/>\s+/, '>').replace(/\s+</, '<') }
        <div class="school-info">
          <a href={entity.links ? entity.links.profile : '#'} target="_blank">{entity.name}</a>
          {entity.type == 'school' && entity.address &&
            <div>
              <div class="address">{addressString}</div>
              <div class="school-subinfo"><span>{typeString}</span></div>
              <div class="other-links">
                <span class="icon-house">  </span>
                <a href={homesForSaleHref} rel="nofollow" target="_blank">Homes for sale</a>
              </div>
            </div>
          }
          { entity.schoolCountsByLevelCode && <div><br/>Number of schools:<div>{levelMarkup(entity)}</div></div> }
        </div>
      </div>
    </div>
  );
  return jsxToString(contentString);
}
