import EmailJoinModal from './email_join_modal';
import { create } from 'lodash';

const SignupAndFollowSchoolModal = function($, options) {
  EmailJoinModal.call(this, $, options);
  options = options || {};

  this.cssClass = options.cssClass || 'js-email-join-for-school-profile-modal';
  this.modalUrl = '/gsr/modals/signup_and_follow_school_modal';
  this.deferred.always(function(){
        $.cookie('profileModal', 'true', {expires: 1, path: '/' });
    });
  this.eventTrackingConfig = {
    'default': {
      'show': {
        'eventCategory': 'Registration',
        'eventAction': 'Email Hover',
        'eventLabel': 'GS Newsletter/MSS'
      }
    },
    'profile after delay': {
      'show': {
        'eventCategory': 'User Interruption',
        'eventAction': 'Hover',
        'eventLabel': 'GS Profile Newsletter/MSS',
        'eventNonInt': true
      }
    }
  };
};

SignupAndFollowSchoolModal.prototype = create(EmailJoinModal.prototype, {
  'constructor': EmailJoinModal
});

export default SignupAndFollowSchoolModal;
