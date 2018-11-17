import React from 'react';
import PropTypes from 'prop-types';
import { capitalize, t } from 'util/i18n';
import { renderAssignedTooltip } from 'react_components/search/tooltips'
import { clarifySchoolType } from 'util/school';
import { links, anchorObject } from 'components/links';
import FiveStarRating from '../review/form/five_star_rating';
import RatingWithTooltip from 'react_components/rating_with_tooltip';
import ModalTooltip from "../modal_tooltip";
import RatingWithBar from 'react_components/equity/graphs/rating_with_bar';
import CompareContext from './compare_context';

const renderEnrollment = enrollment => {
  if (enrollment) {
    return enrollment;
  }
  return <span>N/A</span>;
};

const numReviewsLink = (numReviews, reviewsUrl) => {
  return (
    numReviews && numReviews > 0 ? (
      <a href={reviewsUrl}>
        {numReviews} {numReviews > 1 ? t('reviews.reviews') : t('reviews.review')}
      </a>
    ) : (
        t('reviews.No reviews yet')
      )
  )
}

const fiveStars = numFilled => (
  <FiveStarRating questionId={1} value={numFilled} onClick={() => { }} />
);

const CompareSchoolTableRow = ({
  id,
  state,
  name,
  address,
  schoolType,
  gradeLevels,
  levelCode,
  enrollment,
  rating,
  ratingScale,
  testScoreRatingForEthnicity, // test score rating for an ethnic breakdown selected by user
  pinned,  // flag identifying which school user is comparing against
  links,   // object with link to school profile and deep-linked link to reviews
  columns,
  ethnicityInfo,
  savedSchool,
}) => {
  let addressPhrase = [address.street1, address.city, state, address.zip]
    .filter(s => !!s && s.length > 0)
    .join(', ');
  if (!address.city || !state) {
    addressPhrase = null;
  }

  const schoolCard = () => {
    return (
      <td className={pinned ? 'school pinned' : 'school'}>
        {pinned && <div>COMPARE THIS SCHOOL TO SCHOOLS BELOW</div>}
        <React.Fragment key={state + id}>
          <span><RatingWithTooltip rating={rating} ratingScale={ratingScale} /></span>
          <span>
            <a href={links.profile} className="name" target="_blank">
              {name}
            </a>
            <br />
            {addressPhrase && <div className="address">{addressPhrase}</div>}
          </span>
        </React.Fragment>
      </td>
    )
  };

  const cohortPercentageForEthnicity = () => {
    return (
      <CompareContext.Consumer>
        {({breakdown}) =>
          `${ethnicityInfo.find((ethnicityVal) => ethnicityVal.label === breakdown).percentage.toString()}%`
        }
      </CompareContext.Consumer>
    )
  }

  let content = compareColumns(cohortPercentageForEthnicity(),testScoreRatingForEthnicity)
  return (
    <tr className={pinned && 'row-outline'}>
      {schoolCard()}
      {content}
    </tr>
  );
};

const reviewType = (numReviews, reviews, parentRating) => {
  return (
    <React.Fragment>
      {numReviewsLink(numReviews, reviews)}
      {(parentRating ? fiveStars(parentRating) : null)}
    </React.Fragment>
  )
}

const compareColumns = (enrollmentForEthnicity, testScoreRatingForEthnicity) => {
  return (
    <CompareContext.Consumer>
      {({sort}) => (
        <React.Fragment>
          <td className="centered">{enrollmentForEthnicity}</td>
          <td className={sort === 'breakdown-test-score' ? 'yellow-highlight' : ''}>
            <RatingWithBar score={testScoreRatingForEthnicity} size='small'/>
          </td>
        </React.Fragment>
      )}
    </CompareContext.Consumer>
  )
};

const renderNoInfoTooltip = () => {
  const noInfo =
    <div className="tooltip-content">
      <p>{t('no_info')}
        <a href={links.tableview_faq} target="_blank">
          {` ${t('visit our FAQ page')}.`}
        </a>
      </p>
    </div>;
  return (
    <div className="scale">
      <ModalTooltip content={noInfo}>
        <span className="info-circle icon-info" />
      </ModalTooltip>
    </div>
  )
};

CompareSchoolTableRow.propTypes = {
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
  ethnicityInfo: PropTypes.arrayOf(PropTypes.shape({
    label: PropTypes.string,
    rating: PropTypes.number,
    percentage: PropTypes.string
  })),
  links: PropTypes.shape({
    profile: PropTypes.string.isRequired
  }).isRequired
};

CompareSchoolTableRow.defaultProps = {
  enrollment: null,
  rating: null,
  ratingScale: null,
  active: false,
  studentsPerTeacher: null,
  numReviews: null,
  parentRating: null,
  districtName: null,
  ethnicityInfo: []
};

export default CompareSchoolTableRow;
