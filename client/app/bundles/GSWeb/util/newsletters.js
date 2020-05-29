// TODO: import I18n
import * as notifications from '../util/notifications';
import { t, preserveLanguageParam } from '../util/i18n';
import {
  isSignedIn,
  isNotSignedIn,
  getSavedSchoolsFromCookie,
  COOKIE_NAME,
  updateNavbarHeart
} from '../util/session';
import modalManager from '../components/modals/manager';
import { merge, pick } from 'lodash';
import { set as setCookie } from 'js-cookie';
import { findSchools, addSchool, deleteSchool, logSchool } from '../api_clients/schools';
import { addSubscription } from '../api_clients/subscriptions';
// Subscribe a user to the GreatNews newsletter.
// Triggers a join modal if not signed in.
export const signupAndGetNewsletter = function(modalOptions) {
  if (isSignedIn()) {
    const url = preserveLanguageParam('/preferences/')
    window.location.href = url
  } else {
    modalManager
      .showModal('EmailJoinModal', modalOptions)
      .done(greatNewsSignUp);
  }
};

export const signUpForGreatNewsAndMss = function(
  modalOptions,
  state,
  schoolId,
  language
) {
  if (isSignedIn()) {
    addSubscription('mystat', state, schoolId, language);
    const url = preserveLanguageParam('/preferences/')
    window.location.href = url
  } else {
    modalManager.showModal('EmailJoinModal', modalOptions).done(() => {
      greatNewsSignUp();
      addSubscription('mystat', state, schoolId, language);
    });
  }
};

// Sign up the user to follow a school.
// Triggers a signupAndFollow modal if not signed in.
export const signupAndFollowSchool = function(state, schoolId, schoolName) {
  if (state && schoolId) {
    updateSavedSchoolsCookie(state, schoolId);
    updateProfileHeart(state, schoolId);
    updateNavbarHeart();

    if ((isSignedIn()) && (savedSchoolsFindIndex(state, schoolId) > -1)) {
      schools(state, schoolId)
        .follow({showMessages: false})
        .done(function(){
          if (schoolName === undefined) {
            notifications.success(
              t('follow_schools.signed_in_message_with_no_school_name')
            );
          } else {
            notifications.success(
              t('follow_schools.signed_in_message') + ' ' + schoolName
            );
          }
        });
    } else if (isNotSignedIn()) {
      modalManager.showModal('SignupAndFollowSchoolModal').done(function(data) {
        schools(state, schoolId).follow({email: data.email});
      }).fail(function(data) {
        if(data && data.hasOwnProperty('error')) {
          notifications.error(data.error);
        }
      });
    }
  }
};

const savedSchoolsFindIndex = function(schoolState, schoolId) {
  return getSavedSchoolsFromCookie().findIndex(
    key =>
        key.id.toString() === schoolId.toString() &&
        key.state === schoolState
  );
}

const updateSavedSchoolsCookie = function(schoolState, schoolId) {
  const savedSchools = getSavedSchoolsFromCookie();
  const schoolKeyIdx = savedSchoolsFindIndex(schoolState, schoolId);
  let removeSchool = schoolKeyIdx > -1;
  schoolKeyIdx > -1
    ? savedSchools.splice(schoolKeyIdx, 1)
    : savedSchools.push({ state: schoolState, id: schoolId.toString() });
  logSchool({state: schoolState, id: schoolId}, (removeSchool ? 'remove' : 'add'), 'school-profile')
  setCookie(COOKIE_NAME, savedSchools);
  const newSchool = { state: schoolState, id: schoolId };
  if (isSignedIn()) {
    if (schoolKeyIdx > -1) {
      deleteSchool(newSchool)
        .done(e => {
          e.status === 400 && alert("There was an error deleting a school from your account.\n Please try again later");
          e.status === 501 && alert("There was an issue deleting the school from your account.\n Please log out and sign back in. Thank you.");
        })
        .fail(e => alert("There was an error deleting a school from your account.\n Please try again later"))
    }
  }
  analyticsEvent('search', 'saveSchool', schoolKeyIdx > -1);
};

export const updateProfileHeart = (schoolState, schoolId) => {
  const heart = document.getElementById('profile-heart');
  const saveText = document.getElementById('save-text');

  const savedSchools = getSavedSchoolsFromCookie();
  const schoolKeyIdx = getSavedSchoolsFromCookie().findIndex(key =>
    key.id.toString() === schoolId.toString() && key.state === schoolState);

  if (schoolKeyIdx > -1) {
    heart.style.setProperty('color', '#2bade3');
    saveText.innerHTML = t('Saved');
  } else {
    heart.style.removeProperty('color');
    saveText.innerHTML = t('Save');
  }
}

const postSubscriptionViaAjax = function(subscriptionParams) {
  return $.ajax({
    type: 'POST',
    url: "/gsr/user/subscriptions",
    data: {
      subscription: subscriptionParams
    }
  });
};

export const sponsorsSignUp = function(options) {
  var subscriptionParams = merge(
    {
      list: 'sponsor',
      message: "You've signed up to receive sponsors updates"
    },
    pick(options, ['email', 'language'])
  );

  return postSubscriptionViaAjax(subscriptionParams);
};

export const teacherSignUp = function (options) {
  var subscriptionParams = merge(
      {
        list: 'teacher_list',
        message: "You've signed up to receive teacher and school official updates"
      },
      pick(options, ['email', 'language'])
  );

  return postSubscriptionViaAjax(subscriptionParams);
};

export const greatNewsSignUp = function(options) {
  options = options || {};
  var subscriptionParams = merge(
    {
      list: 'greatnews'
    },
    pick(options, ['email', 'language'])
  );

  return postSubscriptionViaAjax(subscriptionParams).always(showFlashMessages);
};

export const gradeByGradeSignUp = function(options) {
  options = options || {};
  var subscriptionParams = merge(
    {
      list: 'greatkidsnews'
    },
    pick(options, ['email', 'language'])
  );

  return postSubscriptionViaAjax(subscriptionParams).always(showFlashMessages);
};

const showFlashMessages = function(jqXHR) {
  var data = jqXHR;
  if(jqXHR.hasOwnProperty('responseJSON')) {
    data = jqXHR.responseJSON;
  }
  if (data.hasOwnProperty('flash')) {
    notifications.flash_from_hash(data.flash);
  }
};


// TODO: needs refactoring

// usage:
// schools('CA', 1, {driver: 'Header'}).follow(); # driver means traffic driver (for analytics)
const schools = function(states, schoolIds, options) {
  options = options || {};
  var driver = options.driver || null;
  if(states instanceof Array) {
    states = _(states).join(',');
  }
  if(schoolIds instanceof Array) {
    schoolIds = _(schoolIds).join(',');
  }

  /*
    favorite_school[school_id]:1,2,3
    favorite_school[state]:CA,CA,CA
    favorite_school[driver]:Header
  */
  var makeFollowSchoolAjaxRequest = function(options) {
    var url = '/gsr/user/favorites/';
    url = preserveLanguageParam(url);
    var data = {
      'favorite_school': merge(
        {
          'school_id': schoolIds,
          'state': states
        }, pick(options, ['email', 'language'])
      )
    };
    if (driver) {
      data.favorite_school.driver = driver;
    }
    return $.post(url, data);
  };

  var follow = function(options) {
    options = options || {};
    var showMessages = options.showMessages;
    if(showMessages === undefined) {
      showMessages = true;
    }
    return makeFollowSchoolAjaxRequest(options).always(function(jqXHR) {
      if(showMessages) {
        showFlashMessages(jqXHR);
      }
    });
  };

  return {
    follow: follow
  };
};
