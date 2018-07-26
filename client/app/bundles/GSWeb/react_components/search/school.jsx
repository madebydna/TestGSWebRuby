import React from 'react';
import PropTypes from 'prop-types';
import { capitalize, t } from 'util/i18n';
import ModalTooltip from 'react_components/modal_tooltip';
import unratedSchoolIcon from 'school_profiles/owl.png';
import {
  getHomesForSaleHref,
  studentsPhrase,
  schoolTypePhrase
} from 'util/school';

const joinWithSeparator = (arrayOfElements, separator) =>
  arrayOfElements
    .filter(e => !!e)
    .reduce((list, current) => [list, separator, current]);

const renderRating = (rating, ratingScale) => {
  const className = `circle-rating--small circle-rating--${rating || 'gray'}`;
  const content = (
    <div
      dangerouslySetInnerHTML={{
        __html: rating
          ? t('rating_description_html')
          : t('no_rating_description_html')
      }}
    />
  );
  return (
    <ModalTooltip content={content}>
      <React.Fragment>
        {rating ? 
          <div className={className}>
            {rating}
            {rating && <span className="rating-circle-small">/10</span>}
          </div> : <img alt="Owl icon for unrated school" src={unratedSchoolIcon} />}
        <div className="scale">
          {ratingScale || t('Currently unrated')}
          <span className="info-circle icon-info" />
        </div>
      </React.Fragment>
    </ModalTooltip>
  );
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
      {assigned && <div className="assigned-text">{t('assigned')}</div>}
      <span>{renderRating(rating, ratingScale)}</span>
      <span>
        <a href={links.profile} className="name" target="_blank">
          {name}
        </a>
        <br />
        {addressPhrase && <div className="address">{addressPhrase}</div>}
        <div>
          {joinWithSeparator(
            [
              schoolTypePhrase(schoolType, gradeLevels),
              studentsPhrase(enrollment)
            ],
            <span key="divider" className="divider">
              |
            </span>
          )}
        </div>
        {distance && <div>Distance: {distance} miles</div>}
        {homesForSaleHref && (
          <div>
            <span key="homes-for-sale" className="icon icon-house" />
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
