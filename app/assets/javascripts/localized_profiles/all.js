var GS = GS || {};

GS.schoolProfiles = GS.schoolProfiles || (function($) {

    var shouldShowSignUpForSchoolModal = function() {
     return $.cookie('profileModal') != 'true' && !GS.session.isSignedIn();
    };

    var setSignUpForSchoolModalCookie = function() {
      $.cookie('profileModal', 'true', {expires: 1, path: '/' });
    };

    var showSignUpForSchoolModalAfterDelay = function (custom_modal_delay) {
        var DEFAULT_MODAL_DELAY = 15000;
        var hover_delay = custom_modal_delay !== undefined ? custom_modal_delay : DEFAULT_MODAL_DELAY;
        GS.schoolProfiles.hover_time_out = setTimeout(
        // Named function hover_handle used for changing delay in optimizely    
            GS.schoolProfiles.hover_handle = function () {
            showSignUpForSchoolModal();
            },
            hover_delay);
    };



    var showSignUpForSchoolModal = function () {
      if ( shouldShowSignUpForSchoolModal() ) {
        if(!GS.session.isSignedIn()) {
          GS.modal.manager.showModal(GS.modal.SignupAndFollowSchoolModal, {
            placeWhereModalTriggered: 'profile after delay'
          }).done(function(data) {
            var state = GS.stateAbbreviationFromUrl();
            var schoolId = GS.schoolIdFromUrl();
            GS.subscription.schools(state, schoolId).follow(data);
          }).always(function() {
            setSignUpForSchoolModalCookie();
          });
        }
      }
    };

    var initializeSaveThisSchoolButton = function() {
      $('.js-save-this-school-button').on('click', function () {
        var state = GS.stateAbbreviationFromUrl();
        // save this school button on profiles gets id from url
        // save this school button on compare search gets school id from link value
        var schoolId = GS.schoolIdFromUrl() || $(this).data('link-value');
        GS.sendUpdates.signupAndFollowSchool(state, schoolId);
      });
    };

    var initializeFollowThisSchool = function() {
      $('.js-followThisSchool').on('click', function () {
        var state = GS.stateAbbreviationFromUrl();
        var schoolId = GS.schoolIdFromUrl();
        GS.sendUpdates.signupAndFollowSchool(state, schoolId);
      });
    };

    var showDetailsOverviewSection = function() {
      $('.js-overview-details').removeClass('dn');
      GS.ad.showAd('School_OverviewDetails_AdaptiveAd');
    };

    return {
      showSignUpForSchoolModal: showSignUpForSchoolModal,
      showSignUpForSchoolModalAfterDelay: showSignUpForSchoolModalAfterDelay,
      initializeFollowThisSchool: initializeFollowThisSchool,
      initializeSaveThisSchoolButton: initializeSaveThisSchoolButton,
      showDetailsOverviewSection: showDetailsOverviewSection
    };

  })(jQuery);
