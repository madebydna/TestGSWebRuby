import React from 'react';
import PropTypes from 'prop-types';
import { t } from 'util/i18n';
import csaBadgeGenLg from 'school_profiles/csa_generic_badge_lg_icon.png';
import owlPng from 'school_profiles/owl.png';

const CsaInfo = ({ locality, caAdvocacy }) => {
  let moduleIcon = csaBadgeGenLg;
  let headerText = `${t('award_winners')}`;
  let blurbText = `${t("csa_district_schools_info_html")}`;
  let buttonText = `${t('see_winning_schools_in')} ${locality.stateLong}`;

  if (caAdvocacy) {
    moduleIcon = owlPng;
    headerText = `CA header text`;
    blurbText = `CA blurb text`;
    buttonText = `CA button text`;
  }

  return (
    <div className="csa-state-module">
      <h3>{headerText}</h3>
      <div className="csa-state-blurb">
        <img 
          src={moduleIcon}
          className="csa-badge-gen-lg"
          alt="csa-badge-icon"
        />
        <p>
          <span dangerouslySetInnerHTML={{__html: blurbText }}/>
        </p>
      </div>
      <div className="csa-state-module-divider">
        <div className="blue-line" />
      </div>
      <div className="more-school-btn">
        <a href={locality.stateCsaBrowseUrl}>
          <button>{buttonText}</button>
        </a>
      </div>
    </div>
  );
}

export default CsaInfo;