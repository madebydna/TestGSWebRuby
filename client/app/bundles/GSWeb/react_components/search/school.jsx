import React from 'react';
import PropTypes from 'prop-types';
import { capitalize, t } from 'util/i18n';
import ModalTooltip from 'react_components/modal_tooltip';

const renderRating = (rating, ratingScale) => {
  const className = `circle-rating--small circle-rating--${rating}`;
  const content = (
    <div dangerouslySetInnerHTML={{ __html: t('rating_description_html') }} />
  );
  return (
    <React.Fragment>
      <div className={className}>
        {rating}
        <span className="rating-circle-small">/10</span>
      </div>
      <div className="scale">
        <ModalTooltip content={content}>
          {ratingScale}
          <span className="info-circle icon-info" />
        </ModalTooltip>
      </div>
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
  if (!enrollment) {
    return null;
  }
  return (
    <span>
      <span className="open-sans_semibold">{enrollment}</span>
      {enrollment > 1 ? ' students' : ' student'}
    </span>
  );
};

const schoolTypePhrase = (schoolType, gradeLevels) => (
  <span className="open-sans_semibold">
    {capitalize(schoolType)}, {gradeLevels}
  </span>
);

const School = ({
  id,
  state,
  name,
  address,
  schoolType,
  gradeLevels,
  enrollment,
  rating,
  ratingScale,
  active,
  distance,
  assigned,
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
      {assigned && <div className='assigned-text'>ASSIGNED</div>}
      <span>{rating && renderRating(rating, ratingScale)}</span>
      <span>
        <a href={links.profile} className="name" target="_blank">
          {name}
        </a>
        <br />
        {addressPhrase && <div className="address">{addressPhrase}</div>}
        <div>
          {[
            schoolTypePhrase(schoolType, gradeLevels),
            studentsPhrase(enrollment)
          ].reduce((accum, el) => {
            if (accum.length > 0) {
              return el === null
                ? accum
                : [
                    ...accum,
                  <span style={{ color: '#bbc0ca', padding: '0 5px' }}>
                    {' '}
                      |{' '}
                  </span>,
                    el
                  ];
            }
            return el === null ? accum : [...accum, el];
          }, [])}
        </div>
        {distance && <div>Distance: {distance} miles</div>}
        {homesForSaleHref && (
          <div>
            <span className="icon icon-house" />
            <a
              href={homesForSaleHref}
              target="_blank"
              className="homes-for-sale-link"
            >
              &nbsp; Homes for sale
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
  ratingScale: PropTypes.string,
  active: PropTypes.bool,
  links: PropTypes.shape({
    profile: PropTypes.string.isRequired
  }).isRequired
};

School.defaultProps = {
  enrollment: null,
  rating: null,
  ratingScale: null,
  active: false
};

export default School;
