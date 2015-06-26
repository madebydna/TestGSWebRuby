var GS = GS || {};

GS.schoolProfiles = GS.schoolProfiles || (function($) {
    var MODAL_DELAY = 15000;

    var shouldShowSignUpForSchoolModal = function() {
     return $.cookie('profileModal') != 'true' && gon.signed_in === false;
    };

    var setSignUpForSchoolModalCookie = function() {
      $.cookie('profileModal', 'true', {expires: 1});
    };

    var showSignUpForSchoolModalAfterDelay = function () {
      setTimeout(function() { 
        showSignUpForSchoolModal();
        }, MODAL_DELAY);
    };

    var showSignUpForSchoolModal = function () {
      if ( shouldShowSignUpForSchoolModal() ) {
        GS.modal.manager.displayModal(GS.modal.signUpForSchool)
        .done(function() {
          setSignUpForSchoolModalCookie();
        })
      }
    };

    return {
      showSignUpForSchoolModal: showSignUpForSchoolModal,
      showSignUpForSchoolModalAfterDelay: showSignUpForSchoolModalAfterDelay
    };

  })(jQuery);

