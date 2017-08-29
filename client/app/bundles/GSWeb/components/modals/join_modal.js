import { create, assign } from 'lodash';

// TODO: import Facebook methods
import BaseModal from './base_modal';
import { signinToFacebookThenGreatSchools } from '../../components/facebook_auth';
import { runValidations as runFormValidations } from 'components/validating_forms';

const JoinModal = function($, options) {
  BaseModal.call(this, $, options);
  options = options || {};

  this.cssClass = options.cssClass || 'js-join-modal';
  this.modalUrl = '/gsr/modals/join_modal';

  this.eventTrackingConfig = {
    'default': {
      'show': {
        'eventCategory': 'Registration',
        'eventAction': 'Sign-in Hover',
        'eventLabel': 'GS Sign-in/Join'
      }
    }
  };
};

JoinModal.prototype = create(BaseModal.prototype, {
  'constructor': BaseModal
});

assign(JoinModal.prototype, {

    $getJoinSubmitButton: function $getJoinSubmitButton() {
        return this.$getJoinForm().find('button[type="submit"]');
    },

    $getSigninSubmitButton: function $getSigninSubmitButton() {
        return this.$getSigninForm().find('button');
    },

    $getJoinForm: function $getJoinForm() {
        return this.$getModal().find('.js-join-form');
    },

    $getSigninForm: function $getSigninForm() {
        return this.$getModal().find('.js-signin-form');
    },

    preventInteractions: function preventInteractions() {
        this.$getJoinSubmitButton().prop('disabled', true);
        this.$getSigninSubmitButton().prop('disabled', true);
    },

    allowInteractions: function allowInteractions() {
        this.$getJoinSubmitButton().prop('disabled', false);
        this.$getSigninSubmitButton().prop('disabled', false);
    },

    submitSuccessHandler: function submitSuccessHandler(data) {
        this.getDeferred().resolveWith(this, [data]);
        this.allowInteractions();
    },

    facebookSignInSuccessHandler: function facebookSignInSuccessHandler(data) {
        this.getDeferred().resolveWith(this, [data]);
        this.allowInteractions();
    },

    facebookSignInFailHandler: function facebookSignInSuccessHandle(data) {
        var defaultMessage = 'Oops! There was an error signing into your facebook account.';
        jQuery('.js-facebook-signin-errors').html(data || defaultMessage);
        this.allowInteractions();
    },

    submitSignInFailHandler: function submitSignInFailHandler(jqXHR) {
        var defaultMessage = 'There was an error signing into your account.';
        var inLineErrorMessage = this.getInLineErrorMessage(defaultMessage, jqXHR);
        jQuery('.js-signin-email-errors').html(inLineErrorMessage);
        this.allowInteractions();
    },

    submitJoinFailHandler: function submitJoinFailHandler(jqXHR) {
        var defaultMessage = 'There were was an error registering your account.';
        var inLineErrorMessage = this.getInLineErrorMessage(defaultMessage, jqXHR);
        jQuery('.js-join-email-errors').html(inLineErrorMessage);
        this.allowInteractions();
    },

    getInLineErrorMessage: function getInLineErrorMessage(defaultMessage, jqXHR) {
        var inLineErrorMessage = defaultMessage;
        if (jqXHR && jqXHR.responseJSON && jqXHR.responseJSON.error) {
            inLineErrorMessage = jqXHR.responseJSON.error;
        }
        return inLineErrorMessage;
    },

    initializeFacebookSignIn: function initializeFacebookSignIn() {
     var _this = this;
     this.$getModal().on('click', '.js-facebook-signin', function (){
       signinToFacebookThenGreatSchools().done(_this.facebookSignInSuccessHandler.bind(_this)).
       fail(_this.facebookSignInFailHandler.bind(_this))
     });
    },

    joinSubmitHandler: function joinSubmitHandler(event) {
      runFormValidations(event.currentTarget).
        done(() => {
          this.preventInteractions();
          this.postJoinForm()
            .done(this.submitSuccessHandler.bind(this))
            .fail(this.submitJoinFailHandler.bind(this));
        })
      return false;
    },

    signinSubmitHandler: function signinSubmitHandler(event) {
      runFormValidations(event.currentTarget).
        done(() => {
          this.preventInteractions();
          this.postSigninForm()
            .done(this.submitSuccessHandler.bind(this))
            .fail(this.submitSignInFailHandler.bind(this));
        })
      return false;
    },

    postJoinForm: function postJoinForm() {
      let data = this.$getJoinForm().serialize();
      let action = this.$getJoinForm().attr('action');
      return $.post(action, data);
    },

    postSigninForm: function postSigninForm() {
      let data = this.$getSigninForm().serialize();
      let action = this.$getSigninForm().attr('action');
      return $.post(action, data);
    },

    initializeForm: function initializeForm() {
        this.$getJoinForm().on('submit', this.joinSubmitHandler.bind(this));
        this.$getSigninForm().on('submit', this.signinSubmitHandler.bind(this));
    },

    showJoinTab: function showJoinTab() {
      this.$getModal().find('a[href="#login"]').closest('.tab-pane').addClass('active');
      this.$getModal().find('a[href="#join"]').closest('.tab-pane').removeClass('active');
    },

    showSigninTab: function showSigninTab() {
      this.$getModal().find('a[href="#login"]').closest('.tab-pane').removeClass('active');
      this.$getModal().find('a[href="#join"]').closest('.tab-pane').addClass('active');
    },

    initializeEventHandlersForTabs: function initializeEventHandlersForTabs() {
      // See description of why this is needed here: https://jira.greatschools.org/browse/JT-106
      this.$getModal().on('click', 'a[href="#login"]', this.showSigninTab.bind(this));
      this.$getModal().on('click', 'a[href="#join"]', this.showJoinTab.bind(this));

    },

    initialize: function initialize() {
      this.initializeShowHideBehavior();
      this.initializeForm();
      this.initializeFacebookSignIn();
      this.initializeEventHandlersForTabs();
    }

});

export default JoinModal;
