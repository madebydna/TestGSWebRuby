import React from 'react';
import PropTypes from 'prop-types';
import { capitalize, t } from 'util/i18n';
import ModalTooltip from 'react_components/modal_tooltip';
import { renderAssignedTooltip } from 'react_components/search/tooltips'
import { getHomesForSaleHref, clarifySchoolType } from 'util/school';
import FiveStarRating from '../review/form/five_star_rating';
import unratedSchoolIcon from 'school_profiles/owl.png';
import Rating from '../../components/rating';

const renderRating = (rating, ratingScale) => {
  const className = `circle-rating--small circle-rating--${rating}`;
  const content = (
    <div dangerouslySetInnerHTML={{ __html: t('rating_description_html') }} />
  );
  return (
    <React.Fragment>
      <Rating score={rating} size="small" />
      <div className="scale">
        {ratingScale ? ratingScale : t('Currently unrated')}
        <ModalTooltip content={content}>
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
  numReviews && numReviews > 0 ? (
    <a href={reviewsUrl}>
      {numReviews} {numReviews > 1 ? t('reviews.reviews') : t('reviews.review')}
    </a>
  ) : (
    t('reviews.No reviews yet')
  );

const fiveStars = numFilled => (
  <FiveStarRating questionId={1} value={numFilled} onClick={() => {}} />
);

const SchoolTableRow = ({
  id,
  state,
  name,
  address,
  assigned,
  schoolType,
  gradeLevels,
  levelCode,
  enrollment,
  rating,
  ratingScale,
  studentsPerTeacher,
  numReviews,
  parentRating,
  districtName,
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
      <td className="school" style={assigned ? {paddingTop: '28px'} : null}>
        <React.Fragment key={state + id}>
          {assigned && <div className="assigned-school-table-view">{t('assigned_school')}{renderAssignedTooltip(levelCode)}</div>}
          <span>{renderRating(rating, ratingScale)}</span>
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
      <td>{capitalize(clarifySchoolType(schoolType))}</td>
      <td>{gradeLevels}</td>
      <td>{renderEnrollment(enrollment)}</td>
      <td>{studentsPerTeacher ? `${studentsPerTeacher}:1` : 'N/A'}</td>
      <td>
        {numReviewsLink(numReviews, links.reviews)}
        {parentRating ? fiveStars(parentRating) : null}
      </td>
      <td>{districtName ? districtName : 'N/A'}</td>
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
  studentsPerTeacher: PropTypes.number,
  numReviews: PropTypes.number,
  parentRating: PropTypes.number,
  districtName: PropTypes.string,
  links: PropTypes.shape({
    profile: PropTypes.string.isRequired
  }).isRequired
};

SchoolTableRow.defaultProps = {
  enrollment: null,
  rating: null,
  ratingScale: null,
  active: false,
  studentsPerTeacher: null,
  numReviews: null,
  parentRating: null,
  districtName: null
};

export default SchoolTableRow;
