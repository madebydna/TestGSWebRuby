GS = GS || {}
GS.auth = GS.auth || (function() {
    // LOGGING OUT
    // There were previous methods in this file for logging out via JS.
    // If you need them for reference, look at git history

    var GS_FACEBOOK_AUTH_URL = "/gsr/session/facebook_auth";

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

    var signinUsingFacebookData = function(facebookData) {
      return $.post(GS_FACEBOOK_AUTH_URL, convertFacebookSigninDataToGSSigninData(facebookData));
    };

    return {
      signinUsingFacebookData: signinUsingFacebookData
    };

})();
