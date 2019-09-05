import React from 'react';
import PropTypes from 'prop-types';
import { t } from 'util/i18n';
import csaBadgeGenLg from 'school_profiles/csa_generic_badge_lg_icon.png';
import owlQuestionPng from 'community/owl_question.png';

const CsaInfo = ({ community, locality, caAdvocacy }) => {
  let moduleIcon = csaBadgeGenLg;
  let headerText = t('award_winners');
  let blurbText = t('csa_district_schools_info_html');
  let buttonText = `${t('see_winning_schools_in')} ${locality.stateLong}`;
  let buttonLink = locality.stateCsaBrowseUrl;

  if (caAdvocacy && community === 'district') {
    moduleIcon = owlQuestionPng;
    headerText = t('ca_csa_advocacy.district_header');
    blurbText = t('ca_csa_advocacy.district_body');
    buttonText = t('ca_csa_advocacy.district_button');
    buttonLink = locality.caAdvocacyUrl;
  } else if (caAdvocacy && community === 'school') {
    moduleIcon = owlQuestionPng;
    headerText = t('ca_csa_advocacy.school_header');
    blurbText = t('ca_csa_advocacy.school_body');
    buttonText = t('ca_csa_advocacy.school_button');
    buttonLink = locality.caAdvocacyUrl;
  } else if (caAdvocacy) {
    moduleIcon = owlQuestionPng;
    headerText = t('ca_csa_advocacy.state_header');
    blurbText = t('ca_csa_advocacy.state_body');
    buttonText = t('ca_csa_advocacy.state_button');
    buttonLink = locality.caAdvocacyUrl;
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
        <a href={buttonLink}>
          <button>{buttonText}</button>
        </a>
      </div>
    </div>
  );
}

export default CsaInfo;