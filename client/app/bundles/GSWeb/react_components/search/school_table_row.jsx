import React from 'react';
import PropTypes from 'prop-types';
import { capitalize, t } from 'util/i18n';
import { renderAssignedTooltip } from 'react_components/search/tooltips'
import { getHomesForSaleHref, clarifySchoolType } from 'util/school';
import FiveStarRating from '../review/form/five_star_rating';
import RatingWithTooltip from 'react_components/rating_with_tooltip';

const renderEnrollment = enrollment => {
  if (enrollment) {
    return enrollment;
  }
  return <span>N/A</span>;
};

const drawRating = (theRating, linkProfile) => {
  const className = `circle-rating--small circle-rating--${theRating || 'gray'}`;
  return (
      theRating ? <a href={linkProfile}>
            <span className={className}>
              {theRating}
              {theRating && <span className="rating-circle-small">/10</span>}
            </span></a> : <span>N/A</span>
      )
}
const numReviewsLink = (numReviews, reviewsUrl) => {
  return(
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
  links,
  columns,
  tableView,
  subratings,
  ethnicity_ratings
}) => {
  const homesForSaleHref = getHomesForSaleHref(state, address);
  let addressPhrase = [address.street1, address.city, state, address.zip]
      .filter(s => !!s && s.length > 0)
      .join(', ');
  if (!address.city || !state) {
    addressPhrase = null;
  }

  const schoolCard = () => {
    return (
        <td className={`school${assigned ? ' assigned' : ''}`}>
          <React.Fragment key={state + id}>
            {assigned && <div>{t('assigned_school')}{renderAssignedTooltip(levelCode)}</div>}
            <span><RatingWithTooltip rating={rating} ratingScale={ratingScale}/></span>
            <span>
            <a href={links.profile} className="name" target="_blank">
              {name}
            </a>
            <br/>
              {addressPhrase && <div className="address">{addressPhrase}</div>}
              {homesForSaleHref && (
                  <div>
                    <span className="icon icon-house"/>
                    <a
                        href={homesForSaleHref}
                        target="_blank"
                        className="homes-for-sale-link"
                    >
                      &nbsp; {t('homes_for_sale')}
                    </a>
                  </div>
              )}
          </span>
          </React.Fragment>
        </td>
    )
  };

  let content;
  if (tableView == 'Overview') {
    content = overviewColumns(capitalize(clarifySchoolType(schoolType)),
        gradeLevels,
        renderEnrollment(enrollment),
        (studentsPerTeacher ? `${studentsPerTeacher}:1` : 'N/A'),
        reviewType(numReviews, links.reviews, parentRating),
        (districtName ? districtName : 'N/A')
    );
  }
  else if (tableView == 'Equity') {
    content = equityColumns(columns, ethnicity_ratings, links.profile);
  }

  else if (tableView == 'Academic') {
    content = academicColumns(columns, subratings, links.profile);
  }

  return (
      <tr>
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

const overviewColumns = (type, grades, enrollmentDisplay, studentPerTeacher, reviews, district) => {
  return (
      <React.Fragment>
        <td>{type}</td>
        <td>{grades}</td>
        <td>{enrollmentDisplay}</td>
        <td>{studentPerTeacher}</td>
        <td>{reviews}</td>
        <td>{district}</td>
      </React.Fragment>
  )
}

const equityColumns = (columns, ethnicity_ratings, profileLink) => {
  let cellStyle = {textAlign: 'center'}
  let content = [] ;
  columns.map(function(hash, index){
    if (ethnicity_ratings.hasOwnProperty(hash['key'])){
      content.push(<td key={ index } style={cellStyle}>{drawRating(ethnicity_ratings[hash['key']], profileLink)}</td>);
    }
    else{
      content.push(<td key={ index } style={cellStyle}>N/A</td>);
    }
  });
  return (
      <React.Fragment>
        {content}
      </React.Fragment>
  )
}

const academicColumns = (columns, subratings, profileLink) => {
  let cellStyle = {textAlign: 'center'}
  let content = [] ;
    columns.map(function(hash, index){
     if (subratings.hasOwnProperty(hash['key'])){
       content.push(<td key={ index } style={cellStyle}>{drawRating(subratings[hash['key']])}</td>);
     }
     else{
       content.push(<td key={ index } style={cellStyle}>N/A</td>);
     }
  });
  return (
      <React.Fragment>
      {content}
      </React.Fragment>
  )
}

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
