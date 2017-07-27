import JoinModal from './join_modal';

const SubmitReviewModal = function($, options) {
  JoinModal.call(this, $, options);
  options = options || {};

  this.cssClass = options.cssClass || 'js-submit-review-modal';
  this.modalUrl = '/gsr/modals/submit_review_modal';
};

SubmitReviewModal.prototype = _.create(JoinModal.prototype, {
  'constructor': JoinModal
});

export default SubmitReviewModal;
