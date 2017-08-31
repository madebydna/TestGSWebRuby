import React from 'react';
import { t } from '../util/i18n';
import { getState }  from 'store/appStore';
import { signupAndFollowSchool } from 'util/newsletters';

const followSchoolForDataUpdates = function (event) {
  let school = getState().school;
  if(school) {
    return signupAndFollowSchool(school.state, school.id);
  }
};

const NoDataModuleCta = ({moduleName}) => (
  <div className="ptm">
    <span className="no-data" dangerouslySetInnerHTML={{__html: t('no_data_message')}} />
    <a href="javascript:void(0)"
       className="js-followThisSchool js-gaClick"
       onClick={followSchoolForDataUpdates} dangerouslySetInnerHTML={{__html: t('notify_me')}}
       data-ga-click-category='Profile'
       data-ga-click-action='Notify from empty data module'
       data-ga-click-label={moduleName} />
  </div>
);

export default NoDataModuleCta;
