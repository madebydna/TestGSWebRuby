import React from "react";
import PropTypes from "prop-types";
import Button from "../button";
import CsaTopSchoolTableRow from './csa_top_school_table_row';
import School from 'react_components/search/school';
import { t } from "util/i18n";
import { addQueryParamToUrl } from 'util/uri';
import csaBadgeGenLg from 'school_profiles/csa_generic_badge_lg_icon.png';

const CsaTopSchools = ({ schools, renderTabsContainer, size, locality }) => {
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
        { renderTabsContainer() }
        <div className="top-school-info">
          <div className="csa-top-schools-blurb">
            <img 
              src={csaBadgeGenLg} 
              className="csa-badge-gen-lg"
              alt="csa-badge-icon"
              />
            <p>
              <span dangerouslySetInnerHTML={{__html: t('csa_district_schools_info_html')}}/>
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