var GS = GS || {};

GS.subscription = GS.subscription || (function() {

    var postSubscriptionViaAjax = function(subscriptionParams) {
      return $.ajax({
        type: 'POST',
        url: "/gsr/user/subscriptions",
        data: {
          subscription: subscriptionParams
        }
      });
    };

    var sponsorsSignUp = function(options) {
      var subscriptionParams = _.merge(
        {
          list: 'sponsor',
          message: "You've signed up to receive sponsors updates"
        },
        _.pick(options, 'email')
      );

      return postSubscriptionViaAjax(subscriptionParams);
    };

    var greatNewsSignUp = function(options) {
      options = options || {};
      var subscriptionParams = _.merge(
        {
          list: 'greatnews'
        },
        _.pick(options, 'email')
      );

      return postSubscriptionViaAjax(subscriptionParams).always(showFlashMessages);
    };

    var showFlashMessages = function(jqXHR) {
      var data = jqXHR;
      if(jqXHR.hasOwnProperty('responseJSON')) {
        data = jqXHR.responseJSON;
      }
      if (data.hasOwnProperty('flash')) {
        GS.notifications.flash_from_hash(data.flash);
      }
    };

    // usage:
    // GS.subscription.schools('CA', 1, {driver: 'Header'}).follow(); # driver means traffic driver (for analytics)
    var schools = function(states, schoolIds, options) {
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
          if  (showMessages === undefined) {
              showMessages = true;
          }
        return makeFollowSchoolAjaxRequest(options)
          .always(function(jqXHR) {
            if(showMessages) {
              showFlashMessages(jqXHR);
            }
          }
        );
      };

      return {
        follow: follow
      };
    };

    return {
      sponsorsSignUp: sponsorsSignUp,
      greatNewsSignUp: greatNewsSignUp,
      schools: schools
    }

})();


