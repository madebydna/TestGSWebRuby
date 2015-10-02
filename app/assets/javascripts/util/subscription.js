var GS = GS || {};

GS.subscription = GS.subscription || (function() {

    var sponsorsSignUp = function() {
      return $.ajax({
        type: 'POST',
        url: "/gsr/user/subscriptions",
        data: {subscription:
        {list: "sponsor",
          message: "You've signed up to receive sponsors updates"
        }
        }
      })
    };

    var $getNewsSignUpForm = function() {
      var selector = '#js-send-me-updates-form-footer';
      return $(selector);
    };

    var greatNewsSignUp = function() {
      $getNewsSignUpForm().submit();
    };

    var initGreatNewsFormHandlers = function() {
      function flashMessages(event, jqXHR, options, data) {
        if (jqXHR.hasOwnProperty('flash')) {
          GS.notifications.flash_from_hash(jqXHR.flash);
        }
      }

      $getNewsSignUpForm()
        .on('ajax:success', flashMessages)
        .on('ajax:error', flashMessages);
    };


    // usage:
    // GS.subscription.schools('CA', 1, {driver: 'Header'}).follow(); # driver means traffic driver (for analytics)
    var schools = function(states, schoolIds, options) {
      options = options || {};
      var driver = options.driver || null;
      if(!states instanceof Array) {
        states = _.join(states, ',');
      }
      if(!schoolIds instanceof Array) {
        schoolIds = _.join(schoolIds, ',');
      }

      /*
       favorite_school[school_id]:1,2,3
       favorite_school[state]:CA,CA,CA
       favorite_school[driver]:Header
       */
      var makeFollowSchoolAjaxRequest = function() {
        var url = '/gsr/user/favorites/';
        var data = {
          'favorite_school': {
            'school_id': schoolIds,
            'state': states
          }
        };
        if (driver) {
          data.favorite_school.driver = driver;
        }
        return $.post(url, data);
      };

      var follow = function() {
        return makeFollowSchoolAjaxRequest()
          .always(function(jqXHR) {
            var data = jqXHR;
            if(jqXHR.hasOwnProperty('responseJSON')) {
              data = jqXHR.responseJSON;
            }
            if (data.hasOwnProperty('flash')) {
              GS.notifications.flash_from_hash(data.flash);
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
      initGreatNewsFormHandlers: initGreatNewsFormHandlers,
      schools: schools
    }

})();


