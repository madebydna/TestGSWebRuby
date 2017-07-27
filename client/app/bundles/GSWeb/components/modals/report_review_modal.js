import JoinModal from './join_modal';

const ReportReviewModal = function($, options) {
  JoinModal.call(this, $, options);
  options = options || {};

  this.cssClass = options.cssClass || 'js-report-review-modal';
  this.modalUrl = '/gsr/modals/report_review_modal';
};

ReportReviewModal.prototype = _.create(JoinModal.prototype, {
  'constructor': JoinModal
});

export default ReportReviewModal;
