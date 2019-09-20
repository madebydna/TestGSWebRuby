import React from "react";
import PropTypes from "prop-types";
import { t } from "util/i18n";
import InfoBox from '../school_profiles/info_box';

const XQSchoolBoardFinder = ({ locality }) => {
  const sources = t('xq.sources');

  const addressString = `${locality.address}, ${locality.city}, ${locality.stateShort} ${locality.zipCode}`;
  const encodedAddress = encodeURIComponent(addressString);

  return (
    <div className="xq_school_board_module_container">
      <div className="module-header xq_school_board_module">
        <div className="row">
          <div className="col-xs-12">
            <div className="circle-rating--equity-blue">
              <span className="icon-high-performing-schools" />
            </div>
            <div className="title-container">
              <div>
                <h3 className="title">
                  { t('xq.school_board_finder') }
                </h3>
              </div>
              <span dangerouslySetInnerHTML={{__html: t('xq.learn_more_school_board_html', { parameters: { address: encodedAddress } }) }} />
            </div>
          </div>
        </div>
      </div>

      <div className="module-footer">
        <InfoBox content={sources} element_type="sources" pageType='district'>{ t('See notes') }</InfoBox>
      </div>
    </div>
  );
}

export default XQSchoolBoardFinder;