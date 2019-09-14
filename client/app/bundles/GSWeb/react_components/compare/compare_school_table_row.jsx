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
import Rating from 'components/rating';
import CompareContext from './compare_context';
import PieChart from 'react_components/pie_chart';
import SavedSchoolContext from 'react_components/search/saved_school_context';
import {XS, SM, MD} from 'util/viewport';

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
  sort,
  breakdown,
  distance,
  size
}) => {
  let addressPhrase = [address.street1, address.city, state, address.zip]
    .filter(s => !!s && s.length > 0)
    .join(', ');
  if (!address.city || !state) {
    addressPhrase = null;
  }

  const schoolClass = () => {
    let baseClass = pinned ? 'school pinned' : 'school';
    if (['name', 'distance', 'rating'].includes(sort)) {
      return `${baseClass} highlight`
    }
    return baseClass
  }

  const schoolCard = () => {
    return (
      <td className={schoolClass()}>
        {pinned && <div className="compare-schools-pinned-header">{t('compare_pinned_school')}</div>}
        <React.Fragment key={state + id}>
          <span><RatingWithTooltip rating={rating} ratingScale={ratingScale} /></span>
          <span>
            <a href={links.profile} className="name">
              {name}
            </a>
            <br />
            <span>{addressPhrase && <div className="address">{addressPhrase}</div>}</span>
            <div className="school-types">
              {schoolType && <span>{capitalize(t(`school_types.${schoolType}`))}</span>}
              {gradeLevels && <span>, {gradeLevels}</span>}
              {distance !== null && distance !== undefined && distance > 0 && <span>{`  | ${distance} ${t('Miles')}`}</span>}
            </div>
          </span>
          {<SavedSchoolContext.Consumer>
            {({ saveSchoolCallback }) => {
              return <div
                onClick={() => saveSchoolCallback({ state, id: id.toString() })}
                className={savedSchool ? 'icon-heart' : 'icon-heart-outline'}
              />
            }}
          </SavedSchoolContext.Consumer>}
        </React.Fragment>
      </td>
    )
  };

  const cohortPercentageComponent = (percentage) => {
    if(percentage){
      return(
        <div className="cohort-percentages">
          <PieChart slices={[
            {
              color: 'gray',
              value: percentage
            },
            {
              color: '#d3d3d3',
              value: 100 - percentage,
            },
          ]} />
          <span>{`${percentage}%`}</span>
        </div>
      )
    }
    return 'N/A'
  };

  const cohortPercentageForEthnicity = () => {
    const match = ethnicityInfo.find((ethnicityVal) => ethnicityVal.label === breakdown);
    return match && match.percentage;
  };

  const compareColumns = (size) => {
    return (
      <React.Fragment>
        <td className="centered">{enrollment.toLocaleString()}</td>
        {breakdown !== 'All students' && <td className="centered">{cohortPercentageComponent(cohortPercentageForEthnicity())}</td>}
        <td className={`${size < MD ? "centered" : ''} ${sort === 'testscores' ? 'highlight' : ''}`}>
          {size > MD ? 
            <RatingWithBar score={testScoreRatingForEthnicity} size='small' />
            :
            <Rating score={testScoreRatingForEthnicity} size='medium' />
          }
        </td>
      </React.Fragment>
    )
  };


  const shouldRenderSchoolRow = () => {
    let renderRow = false;
    ethnicityInfo.forEach(eth => {
      if (eth.label === breakdown){
        renderRow = true;
      }
    });
    return renderRow;
  };

  return (
    shouldRenderSchoolRow() && (
      <tr className={pinned ? 'row-outline' : undefined}>
        {schoolCard()}
        {compareColumns(size)}
      </tr>
    )
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
      <ModalTooltip content={noInfo} gaCategory='Compare'>
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
    percentage: PropTypes.number
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
