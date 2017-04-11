import React from 'react';

const followSchoolForDataUpdates = function (event) {
  var state = GS.stateAbbreviationFromUrl();
  var schoolId = GS.schoolIdFromUrl();
  return GS.sendUpdates.signupAndFollowSchool(state, schoolId);
};

const NoDataModuleCta = ({moduleName}) => (
  <div className="ptm">
    <span class ="no-data" dangerouslySetInnerHTML={{__html: GS.I18n.t('no_data_message')}} />
    <a href="javascript:void(0)"
       className="js-followThisSchool js-gaClick"
       onClick={followSchoolForDataUpdates} dangerouslySetInnerHTML={{__html: GS.I18n.t('notify_me')}}
       data-ga-click-category='Profile'
       data-ga-click-action='Notify from empty data module'
       data-ga-click-label={moduleName} />
  </div>
);

export default NoDataModuleCta;