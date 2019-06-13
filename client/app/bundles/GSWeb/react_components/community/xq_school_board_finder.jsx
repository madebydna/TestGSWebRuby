import React from "react";
import PropTypes from "prop-types";
import { t } from "util/i18n";
import InfoBox from '../school_profiles/info_box';

const XQSchoolBoardFinder = ({ locality }) => {
  const sources = t('xq.sources');

  const addressString = `${locality.address}, ${locality.city}, ${locality.stateShort} ${locality.zipCode}`;
  const encodedAddress = encodeURIComponent(addressString);

  return (
    <div class="xq_school_board_module_container">
      <div class="module-header xq_school_board_module">
        <div class="row">
          <div class="col-xs-12">
            <div class="circle-rating--equity-blue">
              <span class="icon-high-performing-schools" />
            </div>
            <div class="title-container">
              <div>
                <h3 class="title">
                  { t('xq.school_board_finder') }
                </h3>
              </div>
              <span dangerouslySetInnerHTML={{__html: t('xq.learn_more_school_board_html', { parameters: { address: encodedAddress } }) }} />
            </div>
          </div>
        </div>
      </div>

      <div class="module-footer">
        <InfoBox content={sources} element_type="sources" >{ t('See notes') }</InfoBox>
      </div>
    </div>
  );
}

export default XQSchoolBoardFinder;