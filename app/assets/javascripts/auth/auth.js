GS = GS || {}
GS.auth = GS.auth || (function() {
    // LOGGING OUT
    // There were previous methods in this file for logging out via JS.
    // If you need them for reference, look at git history

    var JOIN_AND_SIGNIN_URL = "/gsr/session/auth";

    // Server handles both join and signin
    var postAjaxSignin = function(data) {
      return $.post(JOIN_AND_SIGNIN_URL, data);
    };

    var convertFacebookSigninDataToGSSigninData = function(facebookData) {
      return {
        email: facebookData.email,
        first_name: facebookData.first_name,
        last_name: facebookData.last_name,
        how: "facebook",
        facebook_id: facebookData.id,
        terms: true,
        facebook_signed_request: facebookData.authResponse.signedRequest
      };
    };

    var signin = function(data) {
      return postAjaxSignin(data);
    };

    var signinUsingFacebookData = function(facebookData) {
      return postAjaxSignin(
        convertFacebookSigninDataToGSSigninData(facebookData)
      );
    };

    return {
      signin: signin,
      signinUsingFacebookData: signinUsingFacebookData
    };

})();