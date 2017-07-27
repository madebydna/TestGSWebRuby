// TODO: import lodash methods

import manager from './manager';
import { addQueryParamToUrl } from '../../util/uri';
import { preserveLanguageParam } from '../../util/i18n';
import log from '../../util/log';

// BaseModal constructor function
const BaseModal = function($, options) {
  // all modals will have these properties, and some should be overwritten within each modal's constructor function
  options = options || {};
  this.cssClass = null;
  this.remodal = null;
  this.modalUrl = null;
  this.deferred = $.Deferred();
  this.$modalContainer = manager.getModalContainer(); // would probably be better to pass modalContainer into constructor
  this.placeWhereModalTriggered = options.placeWhereModalTriggered;
  this.eventTrackingConfig = {};
};

// Add some functions to BaseModal prototype. All modals should share these functions
_.assign(BaseModal.prototype, {
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
    url = addQueryParamToUrl('modal_css_class', this.getCssClass(), url);
    url = preserveLanguageParam(url);
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
          _.merge({
            'event': 'analyticsEvent'
          }, eventTrackingData)
        );
      }
    } catch (e) {
      log(e);
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
    this.$getModal().on('closed', this.rejectIfPending.bind(this));
    this.$getModal().on('hidden.bs.modal', this.rejectIfPending.bind(this));
    this.deferred.always(this.hide.bind(this));
  },

  initialize: function initialize() {}
});

export default BaseModal;

