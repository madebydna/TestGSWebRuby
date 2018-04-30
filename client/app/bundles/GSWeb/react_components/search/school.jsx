import React from 'react';
import { capitalize } from 'util/i18n';

const renderRating = function(rating) {
  let className = 'circle-rating--small circle-rating--' + rating;
  return <div className={className}>
    {rating}
    <span className="rating-circle-small">/10</span>
  </div>;
}

const homesForSaleHref = function(state, address) {
  let homesForSaleHref = null;
  homesForSaleHref = 'https://www.zillow.com/' + state + '-' + address.zip.split("-")[0] + '?cbpartner=Great+Schools&utm_source=GreatSchools&utm_medium=referral&utm_campaign=districtbrowsemap';
  return homesForSaleHref;
}

const School = ({id, state, name, address={}, city, schoolType, gradeLevels, enrollment=null, rating=null, active=false, links={}} = {}) => {
  return (
    <React.Fragment key={state + id}>
      { rating && <span>{renderRating(rating)}</span> }
      <span>
        <a href={links.profile} className="name" target="_blank">{name}</a>
        <br/>
        <div>{address.street1}, {address.city}, {state}, {address.zip}</div>
        <div>{capitalize(schoolType)}, {gradeLevels} | {enrollment} students</div>
        <div className="icon active icon-house">
          <a href={homesForSaleHref(state, address)} target="_blank">Homes for sale</a>
        </div>
      </span>
    </React.Fragment>
  );
}

export default School;
