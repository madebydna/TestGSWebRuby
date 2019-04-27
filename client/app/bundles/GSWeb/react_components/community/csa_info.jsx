import React from 'react';
import PropTypes from 'prop-types';
import { t } from 'util/i18n';
import csaBadgeGenLg from 'school_profiles/csa_generic_badge_lg_icon.png';

const CsaInfo = ({locality, community}) => {
  let buttonText = community === "state" ? t('see_all_winning_schools') : `${t('see_winning_schools_in')} ${locality.stateLong}`;

  return (
    <div className="csa-state-module">
      <h3>{t('award_winners')}</h3>
      <div className="csa-state-blurb">
        <img 
          src={csaBadgeGenLg}
          className="csa-badge-gen-lg"
          alt="csa-badge-icon"
        />
        <p>
          <span dangerouslySetInnerHTML={{__html: t("csa_district_schools_info_html")}}/>
        </p>
      </div>
      <div className="csa-state-module-divider">
        <div className="blue-line" />
      </div>
      <div className="more-school-btn">
        <a href={locality.stateCsaUrl}>
          <button>{buttonText}</button>
        </a>
      </div>
    </div>
  );
}

export default CsaInfo;