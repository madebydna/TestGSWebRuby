var GS = GS || {};
GS.modal = GS.modal || {};

GS.modal.JoinModal = function($, options) {
  GS.modal.BaseModal.call(this, $, options);
  options = options || {};

  this.cssClass = options.cssClass || 'join-modal';
  this.modalUrl = '/gsr/modals/join_modal';
};

GS.modal.JoinModal.prototype = _.create(GS.modal.BaseModal.prototype, {
  'constructor': GS.modal.BaseModal
});

_.assign(GS.modal.JoinModal.prototype, {

  initialize: function initialize() {
  }
});