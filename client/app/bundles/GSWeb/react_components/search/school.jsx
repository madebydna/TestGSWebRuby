import React from 'react';
import PropTypes from 'prop-types';
import { capitalize, t } from 'util/i18n';
import { renderAssignedTooltip } from 'react_components/search/tooltips';
import RatingWithTooltip from 'react_components/rating_with_tooltip';
import {
  getHomesForSaleHref,
  studentsPhrase,
  schoolTypePhrase
} from 'util/school';
import { get as getCookie, set as setCookie } from 'js-cookie';
import { COOKIE_NAME } from './search_context';
import csaBadgeSm from 'search/csa-award-sm.png';
import csaBadgeMd from 'search/csa-award-md.png';
import { name, titleizedName } from 'util/states';
import { legacyUrlEncode } from 'util/uri';

const joinWithSeparator = (arrayOfElements, separator) =>
  arrayOfElements
    .filter(e => !!e)
    .reduce((list, current) => [list, separator, current]);

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
  levelCode,
  active,
  distance,
  assigned,
  links,
  saveSchoolCallback,
  savedSchool,
  csaAwardYears
}) => {
  const homesForSaleHref = getHomesForSaleHref(state, address);
  let addressPhrase = [address.street1, address.city, state, address.zip]
    .filter(s => !!s && s.length > 0)
    .join(', ');
  if (!address.city || !state) {
    addressPhrase = null;
  }

  return (
    <React.Fragment key={state + id + (assigned ? 'assigned' : '')}>
      {assigned && (
        <div>
          {t('assigned_school')} {renderAssignedTooltip(levelCode)}
        </div>
      )}
      <span>
        <RatingWithTooltip rating={rating} ratingScale={ratingScale} />
      </span>
      <span>
        <a href={links.profile} className="name">
          {name}
        </a>
        <br />
        {csaAwardYears.length > 0 && renderCsaBadgePopover(csaAwardYears, links, state)}
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
        {distance !== undefined ? (
          <div>
            {t('Distance')}: {distance} miles
          </div>
        ) : null}
        {homesForSaleHref && (
          <div className="homes-for-sale">
            <span key="homes-for-sale" className="icon icon-house" />
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
      {(saveSchoolCallback) && <span
        onClick={() => saveSchoolCallback({ state, id: id.toString() })}
        className={savedSchool ? 'icon-heart' : 'icon-heart-outline'}
      />}
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
