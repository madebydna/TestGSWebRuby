import React from 'react';
import PropTypes from 'prop-types';
import { capitalize, t } from 'util/i18n';
import ModalTooltip from 'react_components/modal_tooltip';
import {
  getHomesForSaleHref,
  studentsPhrase,
  schoolTypePhrase
} from 'util/school';
import FiveStarRating from '../review/form/five_star_rating';

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

const renderEnrollment = enrollment => {
  if (enrollment) {
    return enrollment;
  }
  return <span>N/A</span>;
};

const numReviewsLink = (numReviews, reviewsUrl) =>
  numReviews ? <a href={reviewsUrl}>{numReviews} reviews</a> : 'No reviews yet';

const fiveStars = numFilled => (
  <FiveStarRating questionId={1} value={numFilled} onClick={() => {}} />
);

const SchoolTableRow = ({
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
  studentsPerTeacher,
  numReviews,
  parentRating,
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
    <tr>
      <td className="school">
        <React.Fragment key={state + id}>
          <span>{rating && renderRating(rating)}</span>
          <span>
            <a href={links.profile} className="name" target="_blank">
              {name}
            </a>
            <br />
            {addressPhrase && <div className="address">{addressPhrase}</div>}
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
      </td>
      <td>{capitalize(schoolType)}</td>
      <td>{gradeLevels}</td>
      <td>{renderEnrollment(enrollment)}</td>
      <td>{studentsPerTeacher ? `${studentsPerTeacher}:1` : 'N/A'}</td>
      <td>
        {numReviewsLink(numReviews, links.reviews)}
        {fiveStars(parentRating)}
      </td>
      <td>District url</td>
    </tr>
  );
};

SchoolTableRow.propTypes = {
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

SchoolTableRow.defaultProps = {
  enrollment: null,
  rating: null,
  ratingScale: null,
  active: false
};

export default SchoolTableRow;
