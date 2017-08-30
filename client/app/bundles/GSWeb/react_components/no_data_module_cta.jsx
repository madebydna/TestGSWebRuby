import React from 'react';
import { t } from '../util/i18n';

const followSchoolForDataUpdates = function (event) {
  var state = GS.stateAbbreviationFromUrl();
  var schoolId = GS.schoolIdFromUrl();
  return GS.sendUpdates.signupAndFollowSchool(state, schoolId);
};

const NoDataModuleCta = ({moduleName, message}) => (
  <div className="ptm">
    <span className="no-data" dangerouslySetInnerHTML={{__html: message}} />
    <div className="ptm">
      <span className="no-data ptm" dangerouslySetInnerHTML={{__html: t('no_data_message')}} />
      <a href="javascript:void(0)"
         className="js-followThisSchool js-gaClick"
         onClick={followSchoolForDataUpdates} dangerouslySetInnerHTML={{__html: t('notify_me')}}
         data-ga-click-category='Profile'
         data-ga-click-action='Notify from empty data module'
         data-ga-click-label={moduleName} />
    </div>
  </div>
);

export default NoDataModuleCta;
