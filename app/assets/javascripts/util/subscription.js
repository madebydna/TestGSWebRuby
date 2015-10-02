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

    return {
      sponsorsSignUp: sponsorsSignUp,
      greatNewsSignUp: greatNewsSignUp,
      initGreatNewsFormHandlers: initGreatNewsFormHandlers
    }

})();


