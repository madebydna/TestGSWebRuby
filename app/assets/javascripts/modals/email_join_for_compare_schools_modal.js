var GS = GS || {};
GS.modal = GS.modal || {};

GS.modal.EmailJoinForCompareSchoolsModal = function($, options) {
  GS.modal.EmailJoinModal.call(this, $, options);
  options = options || {};

  this.cssClass = options.cssClass || 'email-join-for-compare-schools';
  this.modalUrl = '/gsr/modals/signup_and_follow_schools_modal';
};

GS.modal.EmailJoinForCompareSchoolsModal.prototype = _.create(GS.modal.EmailJoinModal.prototype, {
  'constructor': GS.modal.EmailJoinModal
});
