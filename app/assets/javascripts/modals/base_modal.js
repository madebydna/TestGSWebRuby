var GS = GS || {};

GS.modal = GS.modal || {};

// BaseModal constructor function
GS.modal.BaseModal = function($, options) {
  // all modals will have these properties, and some should be overwritten within each modal's constructor function
  options = options || {};
  this.cssClass = null;
  this.remodal = null;
  this.modalUrl = null;
  this.deferred = $.Deferred();
  this.$modalContainer = GS.modal.manager.getModalContainer(); // would probably be better to pass modalContainer into constructor
  this.placeWhereModalTriggered = options.placeWhereModalTriggered;
  this.eventTrackingConfig = {};
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

  getPlaceWhereModalTriggered: function getPlaceWhereModalTriggered() {
    return this.placeWhereModalTriggered;
  },

  // This can be overridden. Should return a hash of event data for a single GA event
  getEventTrackingData: function getEventTrackingData(modalEventType) {
    var placeWhereModalTriggered = this.getPlaceWhereModalTriggered() || 'default';
    if(
      this.hasOwnProperty('eventTrackingConfig')
      && this.eventTrackingConfig.hasOwnProperty(placeWhereModalTriggered)
      && this.eventTrackingConfig[placeWhereModalTriggered].hasOwnProperty(modalEventType)
    ) {
      return this.eventTrackingConfig[placeWhereModalTriggered][modalEventType];
    }
  },

  trackEvent: function trackEvent(modalEventType) {
    try {
      var eventTrackingData = this.getEventTrackingData(modalEventType);
      if (eventTrackingData !== undefined) {
        dataLayer.push(
          merge({
            'event': 'analyticsEvent'
          }, eventTrackingData)
        );
      }
    } catch (e) {
      GS.util.log(e);
    }
  },

  show: function show() {
    // if(this.$getModal().hasClass('no-modal'))
    this.remodal = this.$getModal().remodal({appendTo: this.$getModalContainer()});
    this.remodal.open();
    this.trackEvent('show');
    return this.deferred.promise();
  },

  hide: function hide() {
    if(this.isShown()) {
      this.remodal.close();
    }
  },

  isShown: function isShown() {
    // return (this.$getModal().data('bs.modal') || {}).isShown;
    return (this.remodal.getState() == 'opened')
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
    this.$getModal().on('closed', this.rejectIfPending.gs_bind(this));
    this.$getModal().on('hidden.bs.modal', this.rejectIfPending.gs_bind(this));
    this.deferred.always(this.hide.gs_bind(this));
  },

  initialize: function initialize() {}
});
