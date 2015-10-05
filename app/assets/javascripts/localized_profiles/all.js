var GS = GS || {};

GS.schoolProfiles = GS.schoolProfiles || (function($) {
    var MODAL_DELAY = 15000;

    var shouldShowSignUpForSchoolModal = function() {
     return $.cookie('profileModal') != 'true' && gon.signed_in === false;
    };

    var setSignUpForSchoolModalCookie = function() {
      $.cookie('profileModal', 'true', {expires: 1, path: '/' });
    };

    var showSignUpForSchoolModalAfterDelay = function () {
      setTimeout(function() { 
        showSignUpForSchoolModal();
          /* google event trigger */
          dataLayer.push({'event': 'analyticsEvent', 'eventCategory': 'User Interruption', 'eventAction': 'Hover', 'eventLabel': 'GS Profile Newsletter/MSS', 'eventNonInt': true});
        }, MODAL_DELAY);
    };

    var showSignUpForSchoolModal = function () {
      if ( shouldShowSignUpForSchoolModal() ) {
        if(!GS.session.isSignedIn()) {
          GS.modal.manager.showModal(GS.modal.EmailJoinForSchoolProfileModal)
            .done(function() {
              var state = GS.stateAbbreviationFromUrl();
              var schoolId = GS.schoolIdFromUrl();
              GS.subscription.schools(state, schoolId).follow()
                .done(function() {
                  setSignUpForSchoolModalCookie();
                });
            });
        }
      }
    };

    return {
      showSignUpForSchoolModal: showSignUpForSchoolModal,
      showSignUpForSchoolModalAfterDelay: showSignUpForSchoolModalAfterDelay
    };

  })(jQuery);

