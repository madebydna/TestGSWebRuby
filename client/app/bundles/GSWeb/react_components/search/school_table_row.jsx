import React from 'react';
import PropTypes from 'prop-types';
import { capitalize, t } from 'util/i18n';
import { renderAssignedTooltip } from 'react_components/search/tooltips'
import { getHomesForSaleHref, clarifySchoolType } from 'util/school';
import { links, anchorObject } from 'components/links'; 
import FiveStarRating from '../review/form/five_star_rating';
import RatingWithTooltip from 'react_components/rating_with_tooltip';
import ModalTooltip from "../modal_tooltip";
import SavedSchoolContext from './saved_school_context';

const renderEnrollment = enrollment => {
  if (enrollment) {
    return enrollment;
  }
  return <span>N/A</span>;
};

const drawRating = (theRating, linkProfile) => {
  const className = `circle-rating--small circle-rating--${theRating || 'gray'}`;
  return (
      theRating ? <a href={`${linkProfile}`}>
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
  ethnicityInfo,
  savedSchool,
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
                  <div className="homes-for-sale">
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
            {<SavedSchoolContext.Consumer>
              {( {saveSchoolCallback} ) => {
                  return <div
                  onClick={() => saveSchoolCallback( {state, id: id.toString()} )}
                  className={savedSchool ? 'icon-heart' : 'icon-heart-outline'}
              />
            }}
          </SavedSchoolContext.Consumer>}

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
    content = equityColumns(columns, ethnicityInfo, links.profile);
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

const equityColumns = (columns, ethnicityInfo, profileLink) => {
  let cellStyle = {textAlign: 'center'}
  let content = [] ;
  const keys = ethnicityInfo.map(obj => obj.label);
  columns.forEach(function(hash, index){
    if (keys.includes(hash.key)){
      const ethInfoIdx = keys.indexOf(hash.key);
      content.push(
        <td key={index} style={cellStyle}>
          {drawRating(Math.floor(ethnicityInfo[ethInfoIdx].rating), `${profileLink}${anchorObject[hash.key]}`)}
          <p className="percentage-population">
            {ethnicityInfo[ethInfoIdx].percentage ? 
              <React.Fragment>
                <span>{Math.round(ethnicityInfo[ethInfoIdx].percentage)}%</span><br/> {t('of students')}
              </React.Fragment> 
              : 
              <React.Fragment>
                {renderNoInfoTooltip()}
              </React.Fragment>
            }
          </p>
        </td>
      );
    }else{
      content.push(
        <td key={ index } style={cellStyle}>
          <p>N/A</p>
          {renderNoInfoTooltip()}
        </td>
      );
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
  columns.forEach(function(hash, index){
    if (subratings.hasOwnProperty(hash['key'])){
      content.push(<td key={index} style={cellStyle}>{drawRating(subratings[hash['key']], `${profileLink}${anchorObject[hash.key]}`)}</td>);
    }else{
      content.push(
        <td key={ index } style={cellStyle}>
          <p>N/A</p>
          {renderNoInfoTooltip()}
        </td>
      );
    }
  });
  return (
      <React.Fragment>
      {content}
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
  return(
    <div className="scale">
      <ModalTooltip content={noInfo}>
        <span className="info-circle icon-info" />
      </ModalTooltip>
    </div>
  )
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
  ethnicityInfo: PropTypes.arrayOf(PropTypes.shape({
    label: PropTypes.string,
    rating: PropTypes.number,
    percentage: PropTypes.number
  })),
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
  districtName: null,
  ethnicityInfo: []
};

export default SchoolTableRow;
