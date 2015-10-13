var GS = GS || {};
GS.modal = GS.modal || {};

GS.modal.EmailJoinModal = function($, options) {
  // Call BaseModal's constructor first, using this modal as the context
  GS.modal.BaseModal.call(this, $, options);
  options = options || {};

  // set properties specific to this modal
  this.cssClass = options.cssClass || 'email-join-modal';
  this.modalUrl = '/gsr/modals/email_join_modal';
};

// Assign EmailJoinModal's prototype to a new object that inherits BaseModal's prototype.
// Make sure to set EmailJoinModal's prototype's constructor property
GS.modal.EmailJoinModal.prototype = _.create(GS.modal.BaseModal.prototype, {
  'constructor': GS.modal.BaseModal
});

_.assign(GS.modal.EmailJoinModal.prototype, {

  $getSubmitButton: function $getSubmitButton() {
    return this.$getJoinForm().find('button');
  },

  $getJoinForm: function $getJoinForm() {
    return this.$getFirstForm();
  },

  preventInteractions: function preventInteractions() {
    return this.$getSubmitButton().hide();
  },

  allowInteractions: function allowInteractions() {
    return this.$getSubmitButton().show();
  },

  shouldSignUpForSponsor: function shouldSignUpForSponsor() {
    return this.$getJoinForm().find('#sponsors_list').prop('checked');
  },

  submitSuccessHandler: function submitSuccessHandler(event, jqXHR, options, data) {
    var _this = this;
    if (this.shouldSignUpForSponsor()) {
      GS.subscription.sponsorsSignUp(this.getModalData()).done(function(data) {
        _this.getDeferred().resolve(_.merge(jqXHR, _this.getModalData()));
      }).fail(function(data) {
        _this.getDeferred().reject(_.merge(data, _this.getModalData()));
      });
    } else {
      this.getDeferred().resolve(_.merge(jqXHR, _this.getModalData()));
    }
    this.allowInteractions();
  },

  getEmail: function getEmail() {
    return this.$getJoinForm().find('input[name=email]').val();
  },

  // returns data from this modal. Will be passed along when modal's promise is resolved/rejected
  getModalData: function getModalData() {
    return {
      email: this.getEmail()
    }
  },

  submitFailHandler: function submitFailHandler(event, jqXHR, options, data) {
    this.getDeferred().rejectWith(this, [jqXHR]);
    this.allowInteractions();
  },

  initializeForm: function initializeForm() {
    return this.$getJoinForm().
      on('submit', this.preventInteractions.gs_bind(this)).
      on('ajax:success', this.submitSuccessHandler.gs_bind(this)).
      on('ajax:error', this.submitFailHandler.gs_bind(this));
  },

  initialize: function initialize() {
    this.initializeShowHideBehavior();
    this.initializeForm();
  }
});

