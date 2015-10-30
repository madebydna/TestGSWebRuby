var GS = GS || {};
GS.modal = GS.modal || {};

GS.modal.EmailJoinForCompareSchoolsModal = function($, options) {
  GS.modal.EmailJoinModal.call(this, $, options);
  options = options || {};

  this.cssClass = options.cssClass || 'js-email-join-for-compare-schools';
  this.modalUrl = '/gsr/modals/signup_and_follow_schools_modal';

  this.eventTrackingConfig = {
    'default': {
      'show': {
        'eventCategory': 'Registration',
        'eventAction': 'Email Hover',
        'eventLabel': 'GS Newsletter/MSS'
      }
    }
  };
};

GS.modal.EmailJoinForCompareSchoolsModal.prototype = _.create(GS.modal.EmailJoinModal.prototype, {
  'constructor': GS.modal.EmailJoinModal
});
