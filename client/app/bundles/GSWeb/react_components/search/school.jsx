import React from 'react';
import PropTypes from 'prop-types';
import { capitalize } from 'util/i18n';

const renderRating = rating => {
  const className = `circle-rating--small circle-rating--${rating}`;
  return (
    <React.Fragment>
      <div className={className}>
        {rating}
        <span className="rating-circle-small">/10</span>
      </div>
      <div className="scale">Above average</div>
    </React.Fragment>
  );
};

const getHomesForSaleHref = (state, address) => {
  if (state && address && address.zip) {
    let homesForSaleHref = null;
    homesForSaleHref = `https://www.zillow.com/${state}-${
      address.zip.split('-')[0]
    }?cbpartner=Great+Schools&utm_source=GreatSchools&utm_medium=referral&utm_campaign=districtbrowsemap`;
    return homesForSaleHref;
  }
  return null;
};

const studentsPhrase = enrollment => {
  if (enrollment > 1) {
    return `${enrollment} students`;
  }
  return `${enrollment} student`;
};

const School = ({
  id,
  state,
  name,
  address,
  schoolType,
  gradeLevels,
  enrollment,
  rating,
  active,
  distance,
  links
}) => {
  const homesForSaleHref = getHomesForSaleHref(state, address);
  let addressPhrase = [address.street1, address.city, state, address.zip]
    .filter(s => !!s && s.length > 0)
    .join(', ');
  if (!address.city || !state) {
    addressPhrase = null;
  }

  return (
    <React.Fragment key={state + id}>
      <span>{rating && renderRating(rating)}</span>
      <span>
        <a href={links.profile} className="name" target="_blank">
          {name}
        </a>
        <br />
        {addressPhrase && <div className="address">{addressPhrase}</div>}
        <div>
          {capitalize(schoolType)}, {gradeLevels} | {studentsPhrase(enrollment)}
        </div>
        {distance && <div>Distance: {distance} miles</div>}
        {homesForSaleHref && (
          <div className="icon active icon-house">
            <a href={homesForSaleHref} target="_blank">
              Homes for sale
            </a>
          </div>
        )}
      </span>
    </React.Fragment>
  );
};

School.propTypes = {
  id: PropTypes.number.isRequired,
  state: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
  address: PropTypes.shape({}).isRequired,
  schoolType: PropTypes.oneOf(['public', 'private', 'charter']).isRequired,
  gradeLevels: PropTypes.string.isRequired,
  enrollment: PropTypes.number,
  rating: PropTypes.number,
  active: PropTypes.bool,
  links: PropTypes.shape({
    profile: PropTypes.string.isRequired
  }).isRequired
};

School.defaultProps = {
  enrollment: null,
  rating: null,
  active: false
};

export default School;
