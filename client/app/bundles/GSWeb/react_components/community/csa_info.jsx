import React from 'react';
import PropTypes from 'prop-types';
import { t } from 'util/i18n';
import csaBadgeGenLg from 'school_profiles/csa_generic_badge_lg_icon.png';
import owlQuestionPng from 'community/owl_question.png';
import { analyticsEvent } from "util/page_analytics";


const handleTextGrouping = (community, locality, caAdvocacy) => {
  if (caAdvocacy) {
    let textGrouping = community === 'city' ? 'state' : community;
    
    return (
      {
        moduleIcon: owlQuestionPng,
        headerText: t(`ca_csa_advocacy.${textGrouping}_header`),
        blurbText: t(`ca_csa_advocacy.${textGrouping}_body`),
        buttonText: t(`ca_csa_advocacy.${textGrouping}_button`),
        buttonLink: locality.caAdvocacyUrl
      }
    );
  }
    
  return (
    {
      moduleIcon: csaBadgeGenLg,
      headerText: t('award_winners'),
      blurbText: t('csa_district_schools_info_html'),
      buttonText: `${t('see_winning_schools_in')} ${locality.stateLong}`,
      buttonLink: locality.stateCsaBrowseUrl
    }
  );
}
const handleGoogleAnalytics = (community, action, label) => {
  analyticsEvent(community, action, label);
}

const CsaInfo = ({ community, locality, caAdvocacy }) => {
  let { moduleIcon, headerText, blurbText, buttonText, buttonLink } = handleTextGrouping(community, locality, caAdvocacy);
  let gaEvent = caAdvocacy ? 'CSA Advocacy' : 'CSA State List';

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
        <a href={buttonLink} onClick={() => handleGoogleAnalytics(community, gaEvent, `${buttonText} Clicked`)}>
          <button>{buttonText}</button>
        </a>
      </div>
    </div>
  );
}

export default CsaInfo;