var GS = GS || {};

GS.schoolProfiles = GS.schoolProfiles || (function($) {

    var shouldShowSignUpForSchoolModal = function() {
     return $.cookie('profileModal') != 'true' && !GS.session.isSignedIn();
    };

    var setSignUpForSchoolModalCookie = function() {
      $.cookie('profileModal', 'true', {expires: 1, path: '/' });
    };

    var showSignUpForSchoolModalAfterDelay = function (CUSTOM_MODAL_DELAY) {
        var DEFAULT_MODAL_DELAY = 15000;
        var DELAY = CUSTOM_MODAL_DELAY !== undefined ? CUSTOM_MODAL_DELAY : DEFAULT_MODAL_DELAY;
        GS.schoolProfiles.hover_time_out = setTimeout(
            GS.schoolProfiles.have_handle = function () {
            showSignUpForSchoolModal();
            /* google event trigger */
            dataLayer.push({'event': 'analyticsEvent', 'eventCategory': 'User Interruption', 'eventAction': 'Hover', 'eventLabel': 'GS Profile Newsletter/MSS', 'eventNonInt': true});
            },
         DELAY);
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

    var showReviewsSectionAdOnlyOnce = function() {
      if (showReviewsSectionAdOnlyOnce.adShown !== true) {
        var $oldReviewsSection = $('#old-reviews-section');
        var $newReviewsSection = $('#reviews-section');
        if ($oldReviewsSection.is(':visible')) {
          if ($('#School_OverviewReviewsMobile_Ad').is(':visible')) {
            showReviewsSectionAdOnlyOnce.adShown = true;
            GS.ad.showAd('School_OverviewReviewsMobile_Ad');
          } else if ($('#School_OverviewReviewsAd').is(':visible')) {
            showReviewsSectionAdOnlyOnce.adShown = true;
            GS.ad.showAd('School_OverviewReviewsAd');
          } else {
            // don't do anything
          }
        } else if ($newReviewsSection.is(':visible')) {
          showReviewsSectionAdOnlyOnce.adShown = true;
          GS.ad.showAd('School_OverviewReviews_TestAd');
        } else {
          // don't do anything
        }
      }
    };

    var showReviewsSectionOnOverview = function(oldOrNew) {
      var $reviewsSectionToShow;
      var $reviewsSectionToHide;
      if (oldOrNew === 'new') {
        $reviewsSectionToShow = $('#reviews-section');
        $reviewsSectionToHide = $('#old-reviews-section');
      } else {
        $reviewsSectionToShow = $('#old-reviews-section');
        $reviewsSectionToHide = $('#reviews-section');
      }

      $reviewsSectionToHide.hide();
      $reviewsSectionToShow.show({
        complete: function() {
          googletag.cmd.push(function () {
            GS.schoolProfiles.showReviewsSectionAdOnlyOnce();
          });
        }
      });
    };

    return {
      showSignUpForSchoolModal: showSignUpForSchoolModal,
      showSignUpForSchoolModalAfterDelay: showSignUpForSchoolModalAfterDelay,
      initializeFollowThisSchool: initializeFollowThisSchool,
      initializeSaveThisSchoolButton: initializeSaveThisSchoolButton,
      showReviewsSectionOnOverview: showReviewsSectionOnOverview,
      showReviewsSectionAdOnlyOnce: showReviewsSectionAdOnlyOnce
    };

  })(jQuery);
//window.onload = function() {
//    console.log('I m a test for optimizely');
//    if (GS.schoolProfiles.have_handle != undefined) {
//        clearTimeout(GS.schoolProfiles.hover_time_out);
//        GS.schoolProfiles.showSignUpForSchoolModalAfterDelay(60000);
//
//    }
//}
