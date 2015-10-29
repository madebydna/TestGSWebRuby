var GS = GS || {};
GS.modal = GS.modal || {};

GS.modal.SubmitReviewModal= function($, options) {
  GS.modal.JoinModal.call(this, $, options);
  options = options || {};

  this.cssClass = options.cssClass || 'js-submit-review-modal';
  this.modalUrl = '/gsr/modals/submit_review_modal';
};

GS.modal.SubmitReviewModal.prototype = _.create(GS.modal.JoinModal.prototype, {
  'constructor': GS.modal.JoinModal
});
