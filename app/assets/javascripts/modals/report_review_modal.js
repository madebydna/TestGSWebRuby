var GS = GS || {};
GS.modal = GS.modal || {};

GS.modal.ReportReviewModal= function($, options) {
  GS.modal.JoinModal.call(this, $, options);
  options = options || {};

  this.cssClass = options.cssClass || 'js-report-review-modal';
  this.modalUrl = '/gsr/modals/report_review_modal';
};

GS.modal.ReportReviewModal.prototype = _.create(GS.modal.JoinModal.prototype, {
  'constructor': GS.modal.JoinModal
});
