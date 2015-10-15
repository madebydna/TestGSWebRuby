var GS = GS || {};
GS.modal = GS.modal || {};

GS.modal.ReviewVoteModal= function($, options) {
  GS.modal.JoinModal.call(this, $, options);
  options = options || {};

  this.cssClass = options.cssClass || 'js-review-vote-modal';
  this.modalUrl = '/gsr/modals/review_vote_modal';
};

GS.modal.ReviewVoteModal.prototype = _.create(GS.modal.JoinModal.prototype, {
  'constructor': GS.modal.JoinModal
});
