var GS = GS || {};

GS.modal = GS.modal || {};

GS.modal.BaseModal = function() {
  this.cssClass = null;
  this.modalUrl = null;
  this.deferred = $.Deferred();
};

// Add some functions to BaseModal prototype
_.assign(GS.modal.BaseModal.prototype, {
  getCssClass: function getCssClass() {
    return this.cssClass;
  },

  getSelector: function getSelector() {
    return '.' + this.getCssClass();
  },

  $getModal: function $getModal() {
    return $(this.getSelector());
  },

  getModalUrl: function getModalUrl() {
    return this.modalUrl;
  },

  getUrlWithParams: function getUrlWIthParams() {
    var url = this.getModalUrl();
    url = GS.uri.Uri.addQueryParamToUrl('modal_css_class', this.getCssClass(), url);
    url = GS.I18n.preserveLanguageParam(url);
    return url;
  },

  getDeferred: function getDeferred() {
    return this.deferred;
  },

  show: function show() {
    this.$getModal().modal('show');
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
