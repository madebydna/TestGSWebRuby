import React from "react";
import PropTypes from "prop-types";
import Button from "../button";
import CsaTopSchoolTableRow from './csa_top_school_table_row';
import School from 'react_components/search/school';
import { t } from "util/i18n";
import { addQueryParamToUrl } from 'util/uri';
import csaBadgeGenLg from 'school_profiles/csa_generic_badge_lg_icon.png';

const CsaTopSchools = ({ schools, renderTabsContainer, size, locality, community }) => {
  let name;
  if (locality.stateShort === 'DC') {
    name = `${locality.city}, ${locality.stateShort}`;
  } else if (community === 'state') {
    name = locality.nameLong;
  } else {
    name = locality.stateLong;
  }
  
  let schoolList;
  
  schoolList = <section className="top-school-list">
        {schools.map(school => (
          <CsaTopSchoolTableRow
            key={school.state + school.id}
            {...school}
            size={size}
          />
        ))}
      </section>;

	return (
    <div className="top-school-module">
      <div className="profile-module">
        { community === "state" ?
          <h3>{t('award_winning_high_schools')}</h3> : 
          renderTabsContainer()
        }
        <div className="top-school-info">
          <div className="csa-top-schools-blurb">
            <img 
              src={csaBadgeGenLg} 
              className="csa-badge-gen-lg"
              alt="csa-badge-icon"
              />
            <p>
              <span dangerouslySetInnerHTML={{__html: t('top_schools.csa_top_schools_blurb', { parameters: { name } })}}/>
            </p>
          </div>
        </div>
        <hr />
        {schoolList}
        <div className="more-school-btn">
        <a href={locality.stateCsaBrowseUrl}>
            <button>{t('see_all_winning_schools')}</button>
          </a>
        </div>
      </div>
    </div>);
}

CsaTopSchools.propTypes = {
  schools: PropTypes.arrayOf(PropTypes.shape(School.propTypes)).isRequired,
  isLoading: PropTypes.bool
};

CsaTopSchools.defaultProps = {
  schools: []
};

export default CsaTopSchools;