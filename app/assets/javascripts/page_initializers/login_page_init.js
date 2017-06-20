if(gon.pagename == "signin/new"){
  $(function() {
    $('.join-and-login').on('click', '.js-facebook-signin', function() {
      var $joinForm = $('.js-join-form');
      var $signinForm = $('.js-signin-form');
      var $joinSubmitButton = $joinForm.find('button[type="submit"]');
      var $signinSubmitButton = $signinForm.find('button');

      var preventInteractions = function preventInteractions() {
        $joinSubmitButton.prop('disabled', true);
        $signinSubmitButton.prop('disabled', true);
      };

      var allowInteractions = function allowInteractions() {
        $joinSubmitButton.prop('disabled', false);
        $signinSubmitButton.prop('disabled', false);
      };

      var facebookSignInSuccessHandler = function facebookSignInSuccessHandler(data) {
        window.location.pathname = GS.I18n.preserveLanguageParam('/account/');
      };

      var facebookSignInFailHandler = function facebookSignInSuccessHandle(data) {
        var defaultMessage = 'Oops! There was an error signing into your facebook account.';
        $('.js-facebook-signin-errors').html(data || defaultMessage);
        allowInteractions();
      };

      preventInteractions();

      GS.facebook.signinToFacebookThenGreatSchools().
        done(facebookSignInSuccessHandler).
        fail(facebookSignInFailHandler)

      return false;
    });
  });
}
