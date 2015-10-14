var GS = GS || {};
GS.modal = GS.modal || {};

GS.modal.EmailJoinForCompareSchoolsModal = function($, options) {
  GS.modal.EmailJoinModal.call(this, $, options);
  options = options || {};

  this.cssClass = options.cssClass || 'email-join-for-compare-schools';
  this.modalUrl = '/gsr/modals/signup_and_follow_schools_modal';

  this.eventTrackingConfig = {
    //'place modal triggered': {
    //  'modal event type': {
    //    'category': 'A GA Category',
    //    'action': 'An GA Action',
    //    'label': 'A GA Label'
    //  },
    //}
    'compare': {
      'show': {
        'eventCategory': 'Registration',
        'eventAction': 'Email Hover',
        'eventLabel': 'GS Compare Newsletter/MSS'
      }
    }
  }
};

GS.modal.EmailJoinForCompareSchoolsModal.prototype = _.create(GS.modal.EmailJoinModal.prototype, {
  'constructor': GS.modal.EmailJoinModal
});
