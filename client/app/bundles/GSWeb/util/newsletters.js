// TODO: import I18n
import * as notifications from '../util/notifications';
import { t, preserveLanguageParam } from '../util/i18n';
import { isSignedIn } from '../util/session';
import modalManager from '../components/modals/manager';
import { merge, pick } from 'lodash';

// Subscribe a user to the GreatNews newsletter.
// Triggers a join modal if not signed in.
export const signupAndGetNewsletter = function() {
  if (isSignedIn()) {
    greatNewsSignUp();
  } else {
    modalManager
      .showModal('EmailJoinModal')
      .done(greatNewsSignUp);
  }
};

// Sign up the user to follow a school.
// Triggers a signupAndFollow modal if not signed in.
export const signupAndFollowSchool = function(state, schoolId, schoolName) {
  if (state && schoolId) {
    if (isSignedIn()) {
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
    } else {
      modalManager.showModal('SignupAndFollowSchoolModal').done(function(data) {
        schools(state, schoolId).follow({email: data.email});
      });
    }
  }
};

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
    pick(options, 'email')
  );

  return postSubscriptionViaAjax(subscriptionParams);
};

export const greatNewsSignUp = function(options) {
  options = options || {};
  var subscriptionParams = merge(
    {
      list: 'greatnews'
    },
    pick(options, 'email')
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
        }, pick(options, 'email')
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
