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
          GS.modal.manager.showModal(GS.modal.EmailJoinForSchoolProfileModal, {
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
        $self = $(this);
        // save this school button on profiles gets id from url
        // save this school button on compare search gets school id from link value
        var schoolId = GS.schoolIdFromUrl() || $self.data('link-value');
        if (GS.session.isSignedIn()) {
            GS.subscription.schools(state, schoolId).follow({showMessages: false}).done(function(){
                if (GS.schoolNameFromUrl() === undefined) {
                    GS.notifications.notice(GS.I18n.t('follow_schools.signed_in_message_with_no_school_name'));
                } else {
                    GS.notifications.notice(GS.I18n.t('follow_schools.signed_in_message') + ' ' + GS.schoolNameFromUrl());

                }
          });
        } else {
          GS.modal.manager.showModal(GS.modal.EmailJoinForSchoolProfileModal, {
            placeWhereModalTriggered: 'profile header'
          })
            .done(GS.subscription.schools(state, schoolId).follow);
        }
      });
    };

    return {
      showSignUpForSchoolModal: showSignUpForSchoolModal,
      showSignUpForSchoolModalAfterDelay: showSignUpForSchoolModalAfterDelay,
      initializeSaveThisSchoolButton: initializeSaveThisSchoolButton
    };

  })(jQuery);

