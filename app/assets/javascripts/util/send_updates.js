GS = GS || {};

GS.sendUpdates = (function() {

  // Subscribe a user to the GreatNews newsletter.
  // Triggers a join modal if not signed in.
  var signupAndGetNewsletter = function() {
    if (GS.session.isSignedIn()) {
      GS.subscription.greatNewsSignUp();
    } else {
      GS.modal.manager
        .showModal(GS.modal.EmailJoinModal)
        .done(GS.subscription.greatNewsSignUp);
    }
  };

  // Sign up the user to follow a school.
  // Triggers a signupAndFollow modal if not signed in.
  var signupAndFollowSchool = function(state, schoolId, schoolName) {
    if (state && schoolId) {
      if (GS.session.isSignedIn()) {
        GS.subscription
          .schools(state, schoolId)
          .follow({showMessages: false})
          .done(function(){
            if (schoolName === undefined) {
              GS.notifications.success(
                GS.I18n.t('follow_schools.signed_in_message_with_no_school_name')
              );
            } else {
              GS.notifications.success(
                GS.I18n.t('follow_schools.signed_in_message') + ' ' + schoolName
              );
            }
          });
      } else {
        GS.modal.manager.showModal(GS.modal.SignupAndFollowSchoolModal).done(function(data) {
          GS.subscription.schools(state, schoolId).follow({email: data.email});
        });
      }
    }
  };

  return {
    signupAndFollowSchool: signupAndFollowSchool,
    signupAndGetNewsletter: signupAndGetNewsletter,
  };
})();
