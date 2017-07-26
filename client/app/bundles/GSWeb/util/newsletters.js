// TODO: import modals
// TODO: import session
// TODO: import I18n
import * as notifications from '../util/notifications';

// Subscribe a user to the GreatNews newsletter.
// Triggers a join modal if not signed in.
export const signupAndGetNewsletter = function() {
  if (GS.session.isSignedIn()) {
    greatNewsSignUp();
  } else {
    GS.modal.manager
      .showModal(GS.modal.EmailJoinModal)
      .done(greatNewsSignUp);
  }
};

// Sign up the user to follow a school.
// Triggers a signupAndFollow modal if not signed in.
export const signupAndFollowSchool = function(state, schoolId, schoolName) {
  if (state && schoolId) {
    if (GS.session.isSignedIn()) {
      schools(state, schoolId)
        .follow({showMessages: false})
        .done(function(){
          if (schoolName === undefined) {
            notifications.success(
              GS.I18n.t('follow_schools.signed_in_message_with_no_school_name')
            );
          } else {
            notifications.success(
              GS.I18n.t('follow_schools.signed_in_message') + ' ' + schoolName
            );
          }
        });
    } else {
      GS.modal.manager.showModal(GS.modal.SignupAndFollowSchoolModal).done(function(data) {
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

const sponsorsSignUp = function(options) {
  var subscriptionParams = _.merge(
    {
      list: 'sponsor',
      message: "You've signed up to receive sponsors updates"
    },
    _.pick(options, 'email')
  );

  return postSubscriptionViaAjax(subscriptionParams);
};

const greatNewsSignUp = function(options) {
  options = options || {};
  var subscriptionParams = _.merge(
    {
      list: 'greatnews'
    },
    _.pick(options, 'email')
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
    url = GS.I18n.preserveLanguageParam(url);
    var data = {
      'favorite_school': _.merge(
        {
          'school_id': schoolIds,
          'state': states
        }, _.pick(options, 'email')
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


// TODO: remove once modal JS is modularized
window.GS = window.GS || {};
window.GS.subscription = window.GS.subscription || {};
window.GS.subscription.sponsorsSignUp = sponsorsSignUp;
window.GS.subscription.greatNewsSignUp = greatNewsSignUp;
window.GS.subscription.schools = schools;
