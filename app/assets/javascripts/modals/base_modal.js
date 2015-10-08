var GS = GS || {};

GS.modal = GS.modal || {};

// BaseModal constructor function
GS.modal.BaseModal = function($, options) {
  // all modals will have these properties, and some should be overwritten within each modal's constructor function
  this.cssClass = null;
  this.modalUrl = null;
  this.deferred = $.Deferred();
  this.$modalContainer = GS.modal.manager.getModalContainer(); // would probably be better to pass modalContainer into constructor
};

// Add some functions to BaseModal prototype. All modals should share these functions
_.assign(GS.modal.BaseModal.prototype, {
  getCssClass: function getCssClass() {
    return this.cssClass;
  },

  $getModalContainer: function $getModalContainer() {
    return this.$modalContainer;
  },

  $getModal: function $getModal() {
    return this.$getModalContainer().find('.' + this.getCssClass());
  },

  getModalUrl: function getModalUrl() {
    return this.modalUrl;
  },

  // Take the modal's specific URL and tack on lang param and modal's css class
  getUrlWithParams: function getUrlWIthParams() {
    var url = this.getModalUrl();
    url = GS.uri.Uri.addQueryParamToUrl('modal_css_class', this.getCssClass(), url);
    url = GS.I18n.preserveLanguageParam(url);
    return url;
  },

  getDeferred: function getDeferred() {
    return this.deferred;
  },

  sendGoogleAnalyticsPageView: function sendGoogleAnalyticsPageView() {
    // override within specific hovers
  },

  show: function show() {
    this.$getModal().modal('show');
    this.sendGoogleAnalyticsPageView();
    return this.deferred.promise();
  },

  hide: function hide() {
    if(this.isShown()) {
      this.$getModal().modal('hide');
    }
  },

  isShown: function isShown() {
    return (this.$getModal().data('bs.modal') || {}).isShown;
  },

  $getFirstForm: function $getFirstForm() {
    return this.$getModal().find('form:first')
  },

  rejectIfPending: function rejectIfPending() {
    if(this.deferred.state() == 'pending') {
      this.deferred.reject();
    }
  },

  initializeShowHideBehavior: function initializeShowHideBehavior() {
    this.$getModal().on('hidden.bs.modal', this.rejectIfPending.gs_bind(this));
    this.deferred.always(this.hide.gs_bind(this));
  }
});
