import React from 'react';
import PropTypes from 'prop-types';
import { capitalize } from 'util/i18n';
import QuestionMarkTooltip from 'react_components/school_profiles/question_mark_tooltip';

const renderRating = (rating, ratingScale) => {
  const className = `circle-rating--small circle-rating--${rating}`;
  const content = (
    <span>
      <b>The GreatSchools Summary Rating</b> appears at the top of a school’s
      profile and provides an overall snapshot of school quality based on how
      well a school prepares all its students for postsecondary success—be it
      college or career. The Summary Rating calculation is based on five of the
      school’s themed ratings (the Test Score Rating, Student or Academic
      Progress Rating, College Readiness Rating, Equity Rating and Advanced
      Courses Rating) and flags for discipline and attendance disparities at a
      school. The ratings we display for each school can vary based on data
      availability or relevance to a school level (for example, high schools
      will have a College Readiness Rating, but elementary schools will not). We
      will not produce a Summary Rating for a school if we lack sufficient data
      to calculate one. For more about how this rating is calculated, see the
      Summary Rating inputs & weights section below. For more information about
      how we calculate this rating, see the GreatSchools Ratings methodology
      report.
    </span>
  );
  return (
    <React.Fragment>
      <div className={className}>
        {rating}
        <span className="rating-circle-small">/10</span>
      </div>
      <div className="scale">
        <QuestionMarkTooltip content={content}>
          {ratingScale}
        </QuestionMarkTooltip>
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
