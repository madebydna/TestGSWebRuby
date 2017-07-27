import BaseModal from './base_modal';
import { sponsorsSignUp } from '../../util/newsletters';

const EmailJoinModal = function($, options) {
  // Call BaseModal's constructor first, using this modal as the context
  BaseModal.call(this, $, options);
  options = options || {};

  // set properties specific to this modal
  this.cssClass = options.cssClass || 'js-email-join-modal';
  this.modalUrl = '/gsr/modals/email_join_modal';

  this.eventTrackingConfig = {
    //'place where modal triggered': {
    //  'modal event type': {
    //    'eventCategory': 'A GA Category',
    //    'eventAction': 'An GA Action',
    //    'eventLabel': 'A GA Label'
    //  },
    //}
    'default': {
      'show': {
        'eventCategory': 'Registration',
        'eventAction': 'Email Hover',
        'eventLabel': 'GS Weekly Newsletter'
      }
    }
  };
};

// Assign EmailJoinModal's prototype to a new object that inherits BaseModal's prototype.
// Make sure to set EmailJoinModal's prototype's constructor property
EmailJoinModal.prototype = _.create(BaseModal.prototype, {
  'constructor': BaseModal
});

_.assign(EmailJoinModal.prototype, {

  $getSubmitButton: function $getSubmitButton() {
    return this.$getJoinForm().find('button[type="submit"]');
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

  signUpForSponsorsList: function signUpForSponsorsList() {
    if (this.shouldSignUpForSponsor()) {
      return sponsorsSignUp(this.getModalData());
    } else {
      return $.when();
    }
  },

  createStudents: function createStudents() {
    var grades = this.getGrades();

    if(grades.length > 0) {
      return $.post(
        '/gsr/api/students',
        this.getModalData(),
        null,
        'json'
      ).then(function(data) {
        return data.responseJSON;
      }, function(data) {
        return data.responseJSON;
      });
    } else {
      return $.when();
    }
  },

  submitSuccessHandler: function submitSuccessHandler(event, jqXHR, options, data) {
    var _this = this;

    $.when(
      this.signUpForSponsorsList(),
      this.createStudents()
    ).done(function(data1, data2) {
      _this.getDeferred().resolve(_.merge({}, jqXHR, data1, data2, _this.getModalData()));
    }).fail(function(data1, data2) {
      _this.getDeferred().reject(_.merge({}, jqXHR, data1, data2, _this.getModalData()));
    });

    this.allowInteractions();
  },

  getEmail: function getEmail() {
    return this.$getJoinForm().find('input[name=email]').val();
  },

  getGrades: function getGrades() {
    var gradesList = this.$getJoinForm().find('input[name=grades]').val();
    if (gradesList) {
      return gradesList.split(',');
    } else {
      return [];
    }
  },

  // returns data from this modal. Will be passed along when modal's promise is resolved/rejected
  getModalData: function getModalData() {
    return {
      email: this.getEmail(),
      grades: this.getGrades()
    }
  },

  submitFailHandler: function submitFailHandler(event, jqXHR, options, data) {
    this.getDeferred().rejectWith(this, [jqXHR]);
    this.allowInteractions();
  },

  initializeForm: function initializeForm() {
    this.$getJoinForm().parsley();

    return this.$getJoinForm().
      on('submit', this.preventInteractions.bind(this)).
      on('ajax:success', this.submitSuccessHandler.bind(this)).
      on('ajax:error', this.submitFailHandler.bind(this));
  },

  initialize: function initialize() {
    this.initializeShowHideBehavior();
    this.initializeForm();
  }
});

export default EmailJoinModal;
