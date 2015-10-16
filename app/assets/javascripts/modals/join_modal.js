var GS = GS || {};
GS.modal = GS.modal || {};

GS.modal.JoinModal = function($, options) {
  GS.modal.BaseModal.call(this, $, options);
  options = options || {};

  this.cssClass = options.cssClass || 'join-modal';
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

GS.modal.JoinModal.prototype = _.create(GS.modal.BaseModal.prototype, {
  'constructor': GS.modal.BaseModal
});

_.assign(GS.modal.JoinModal.prototype, {

    $getJoinSubmitButton: function $getJoinSubmitButton() {
        return this.$getJoinForm().find('button');
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

    submitSuccessHandler: function submitSuccessHandler(event, data, _, jqXHR) {
        this.getDeferred().resolveWith(this, [data]);
        this.allowInteractions();
    },

    facebookSignInSuccessHandler: function facebookSignInSuccessHandler(data) {
        this.getDeferred().resolveWith(this, [data]);
        this.allowInteractions();
    },

    facebookSignInFailHandler: function facebookSignInSuccessHandle(data) {
        var defaultMessage = 'Oops there was an error signing into your facebook account.';
        jQuery('.js-facebook-signin-errors').html(defaultMessage);
        this.allowInteractions();
    },

     submitSignInFailHandler: function submitSignInFailHandler(event, jqXHR, options, data) {
        var defaultMessage = 'There was an error signing into your account.';
        var inLineErrorMessage = this.getInLineErrorMessage(defaultMessage, jqXHR);
        jQuery('.js-signin-email-errors').html(inLineErrorMessage);
        this.allowInteractions();
    },

    submitJoinFailHandler: function submitJoinFailHandler(event, jqXHR, options, data) {
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
       GS.facebook.signinToFacebookThenGreatSchools().done(_this.facebookSignInSuccessHandler.gs_bind(_this)).
       fail(_this.facebookSignInFailHandler.gs_bind(_this))
     });
    },

    initializeForm: function initializeForm() {
        this.$getJoinForm().parsley();
        this.$getSigninForm().parsley();

        this.$getJoinForm().
            on('submit', this.preventInteractions.gs_bind(this)).
            on('ajax:success', this.submitSuccessHandler.gs_bind(this)).
            on('ajax:error', this.submitJoinFailHandler.gs_bind(this));
        this.$getSigninForm().
            on('submit', this.preventInteractions.gs_bind(this)).
            on('ajax:success', this.submitSuccessHandler.gs_bind(this)).
            on('ajax:error', this.submitSignInFailHandler.gs_bind(this));
    },
    
    initialize: function initialize() {
        this.initializeShowHideBehavior();
        this.initializeForm();
        this.initializeFacebookSignIn();
    }
});

