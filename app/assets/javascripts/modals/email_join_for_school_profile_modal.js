var GS = GS || {};
GS.modal = GS.modal || {};

GS.modal.EmailJoinForSchoolProfileModal = function($, options) {
  GS.modal.EmailJoinModal.call(this, $, options);
  options = options || {};

  this.cssClass = options.cssClass || 'email-join-for-school-profile-modal';
  this.modalUrl = '/gsr/modals/signup_and_follow_school_modal';
};

GS.modal.EmailJoinForSchoolProfileModal.prototype = _.create(GS.modal.EmailJoinModal.prototype, {
  'constructor': GS.modal.EmailJoinModal
});