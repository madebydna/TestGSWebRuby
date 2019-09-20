import React from 'react';
import PropTypes from 'prop-types';
import { capitalize, t } from 'util/i18n';
import { renderAssignedTooltip } from 'react_components/search/tooltips'
import { getHomesForSaleHref, clarifySchoolType, getDistrictHref } from 'util/school';
import { links, anchorObject } from 'components/links'; 
import FiveStarRating from '../review/form/five_star_rating';
import RatingWithTooltip from 'react_components/rating_with_tooltip';
import ModalTooltip from "../modal_tooltip";
import SavedSchoolContext from './saved_school_context';
import PieChart from 'react_components/pie_chart';
import csaBadgeSm from 'search/csa-award-sm.png';
import csaBadgeMd from 'search/csa-award-md.png';
import { name, titleizedName } from 'util/states';
import { legacyUrlEncode } from 'util/uri';

const renderEnrollment = enrollment => {
  if (enrollment) {
    return enrollment;
  }
  return <span>N/A</span>;
};

const renderDistrict = (district_name, district_link) => {
  if (district_name && district_link) {
    return <a href={district_link}>{district_name}</a>;
  }
  else if(district_name) {
    return <span>{district_name}</span>
  }
  return <span>N/A</span>;
};

const drawRating = (theRating, linkProfile) => {
  const className = `circle-rating--small circle-rating--${theRating || 'gray'}`;
  return (
      theRating ? 
        <a href={`${linkProfile}`}>
          <span className={className}>
            {theRating}
            {theRating && <span className="rating-circle-small">/10</span>}
          </span>
        </a> 
        : 
        <span>
          <span>N/A</span>
          {renderNoInfoTooltip()}
        </span>
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

const renderCsaBadgePopover = (years, links, state) => {
  let csaYears = years.join(", ");
  let csaYearsForHeader = <span className="csa-award-count">{years.length}</span>;
  let csaHeader = 
    years.length === 1 ? t('award') : t('awards');
  let csaStateLink = `/${legacyUrlEncode(name(state))}/college-success-award/`;

  return (
    <div className="csa-winner-popover-container">
      <div className="csa-winner">
        <img 
          src={csaBadgeSm} 
          className="csa-badge-sm"
          alt="csa-badge-icon"
        /> 
        <span className="csa-winner-header">{csaYearsForHeader} {csaHeader}</span>
        <span className="info-circle icon-info"></span>
      </div>

      <div className="csa-winner-popover">
        <div className="csa-winner-popover-content">
          <h4 className="csa-winner-popover-header">
            {t('awards_and_badges')}
          </h4>
          <div>
            <img 
              src={csaBadgeMd} 
              className="csa-badge-md"
              alt="csa-badge-icon"
            />
            <div className="csa-winner-popover-text">
              <a href={links.collegeSuccess}>College Success Award</a>
              <div>{csaYears}</div>
            </div>
          </div>
          <a className="csa-winner-popover-state-link" href={csaStateLink}>{t('see_all_winners_in')} {titleizedName(state)}</a>
        </div>
      </div>
    </div>
  );
}

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
  csaAwardYears,
  percentLowIncome,
  collegePersistentData,
  remediationData,
  collegeEnrollmentData,
  activeSort
}) => {
  const homesForSaleHref = getHomesForSaleHref(state, address);
  const districtLink = getDistrictHref(state, address.city, districtName);
  const districtAnchor = <a href={districtLink}>{districtName}</a>
  const pieChartLowIncome =
    <div className="low-income-percentages">
      <PieChart slices={[
        {
          color: 'gray',
          value: parseInt(percentLowIncome)
        },
        {
          color: '#d3d3d3',
          value: 100 - parseInt(percentLowIncome),
        },
      ]} />
      <span>{`${percentLowIncome}`}</span>
    </div>;

  let addressPhrase = null;
  if(address.street1) {
    addressPhrase = [address.street1, address.city, state, address.zip]
        .filter(s => !!s && s.length > 0)
        .join(', ');
    if (!address.city || !state) {
      addressPhrase = null;
    }
  }

  const renderRemediationValue = (remediationData, type) => {
    const remedObj = remediationData.find(rd => rd.subject === type)
    if (remedObj){
      return <div>{remedObj.school_value}</div>
    }else{
      return <div>N/A</div>
    }
  };
  const percentCollegeRemediation = renderRemediationValue(remediationData, 'All subjects')
  const percentCollegeRemediationEnglish = renderRemediationValue(remediationData, 'English')
  const percentCollegeRemediationMath = renderRemediationValue(remediationData, 'Math')
  const clarifiedSchoolType = <div>{capitalize(clarifySchoolType(schoolType))}</div>
  const percentCollegePersistent = <div>{Object.keys(collegePersistentData).length > 0 ? collegePersistentData.school_value : "N/A"}</div>
  const percentEnrolledInCollege = <div>{Object.keys(collegeEnrollmentData).length > 0 ? collegeEnrollmentData.school_value : "N/A"}</div>

  const schoolCard = () => {
    return (
        <td className={`school${assigned ? ' assigned' : ''}`}>
          <React.Fragment key={state + id}>
            {assigned && <div>{t('assigned_school')}{renderAssignedTooltip(levelCode)}</div>}
            <span><RatingWithTooltip rating={rating} ratingScale={ratingScale}/></span>
            <span>
            <a href={links.profile} className="name">
              {name}
            </a>
            <br/>
              {csaAwardYears.length > 0 && renderCsaBadgePopover(csaAwardYears, links, state)}
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
        renderDistrict(districtName, districtLink)
    );
  }
  else if (tableView == 'Equity') {
    content = equityColumns(columns, ethnicityInfo, links.profile, activeSort);
  }

  else if (tableView == 'Academic') {
    content = academicColumns(columns, subratings, links.profile, activeSort);
  }

  else {
    content = <React.Fragment>{columns.map(col => <td style={{textAlign:'center'}}>{eval(col.key)}</td>) }</React.Fragment>
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

const equityColumns = (columns, ethnicityInfo, profileLink, activeSort) => {
  let content = [];
  const keys = ethnicityInfo.map(obj => obj.label);
  
  columns.forEach(function(hash, index) {
    let cellClass = (activeSort === hash.sortName) ? "highlighted-cell" : "standard-cell";
    if (keys.includes(hash.key)) {
      const ethInfoIdx = keys.indexOf(hash.key);
      content.push(
        <td key={index} className={cellClass}>
          {drawRating(ethnicityInfo[ethInfoIdx].rating, `${profileLink}${anchorObject[hash.key]}`)}
          {ethnicityInfo[ethInfoIdx].percentage > 0 && 
            <p className="percentage-population">
              <span>{ethnicityInfo[ethInfoIdx].percentage}%</span><br/> {t('of students')}
            </p>
          }
        </td>
      );
    } else {
      content.push(
        <td key={index} className={cellClass}>
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

const academicColumns = (columns, subratings, profileLink, activeSort) => {
  let content = [];

  columns.forEach(function(hash, index) {
    let cellClass = (activeSort === hash.sortName) ? "highlighted-cell" : "standard-cell";
    if (subratings.hasOwnProperty(hash['key'])) {
      content.push(<td key={index} className={cellClass}>{drawRating(subratings[hash['key']], `${profileLink}${anchorObject[hash.key]}`)}</td>);
    } else {
      content.push(
        <td key={index} className={cellClass}>
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
        <a href={links.tableviewFaq} target="_blank">
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
  }).isRequired,
  activeSort: PropTypes.string
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
  ethnicityInfo: [],
  remediationData: []
};

export default SchoolTableRow;
