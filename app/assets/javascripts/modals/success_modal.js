var GS = GS || {};
GS.modal = GS.modal || {};

GS.modal.SuccessModal = function($, options) {
    GS.modal.JoinModal.call(this, $, options);
    options = options || {};

    this.cssClass = options.cssClass || 'success-modal';
    this.heading = options.heading;
    this.subheading = options.subheading;
    this.modalUrl = '/gsr/modals/success_modal';
    if(this.heading) {
      this.modalUrl = GS.uri.Uri.addQueryParamToUrl('heading', this.heading, this.modalUrl);
    }
    if(this.subheading) {
      this.modalUrl = GS.uri.Uri.addQueryParamToUrl('subheading', this.subheading, this.modalUrl);
    }
};

GS.modal.SuccessModal.prototype = _.create(GS.modal.BaseModal.prototype, {
    'constructor': GS.modal.BaseModal
});

_.assign(GS.modal.SuccessModal.prototype, {

  initialize: function initialize() {
    this.initializeShowHideBehavior();
    this.$getModal().find('button').on('click', function() {
      this.getDeferred().resolve();
    }.bind(this));
  }
});
