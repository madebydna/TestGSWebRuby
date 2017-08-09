import BaseModal from './base_modal';
import { addQueryParamToUrl } from '../../util/uri';
import { preserveLanguageParam } from '../../util/i18n';
import { create, assign } from 'lodash';

const SchoolUserModal = function($, options) {
  BaseModal.call(this, $, options);
  options = options || {};

  this.schoolId = options.schoolId;
  this.state = options.state;
  this.cssClass = options.cssClass || 'js-school-user-modal';
  this.modalUrl = '/gsr/modals/school_user_modal';

  this.schoolUserForm;
  this.selectButtons;
  this.schoolUserValue;
  var schoolUserValue;
};

SchoolUserModal.prototype = create(BaseModal.prototype, {
  'constructor': BaseModal
});

assign(SchoolUserModal.prototype, {

  getUrlWithParams: function getUrlWIthParams() {
    var url = this.getModalUrl();
    url = addQueryParamToUrl('modal_css_class', this.getCssClass(), url);
    url = addQueryParamToUrl('state', this.state, url);
    url = addQueryParamToUrl('school_id', this.schoolId, url);
    url = preserveLanguageParam(url);
    return url;
  },

  selectSchoolUserValue: function() {
    var value = this.dataset.schoolUser;
    schoolUserValue.attr('value', value);
    $(this).siblings().removeClass('active');
    $(this).addClass('active');
  },

  setSelectSchoolUserHandler: function() {
    this.selectButtons.on('click',this.selectSchoolUserValue);
  },

  submitSuccessHandler: function submitSuccessHandler(event, jqXHR, options, data) {
    var _this = this;
    this.getDeferred().resolve();
    // this.getDeferred().resolve(_.merge(jqXHR, _this.getModalData()));
  },

  // returns data from this modal. Will be passed along when modal's promise is resolved/rejected this might be used for submiting reviews with message but may not be needed
  getModalData: function getModalData() {
    return {
      test: 'test'
    }
  },

  submitFailHandler: function submitFailHandler(event, jqXHR, options, data) {
    this.getDeferred().rejectWith(this, [jqXHR]);
  },

  initializeForm: function initializeForm() {
    return this.schoolUserForm.
      on('ajax:success', this.submitSuccessHandler.bind(this)).
      on('ajax:error', this.submitFailHandler.bind(this));
  },

  initializeVariables: function initializeVariables(){
    this.schoolUserForm = this.$getFirstForm();
    this.selectButtons = this.schoolUserForm.find('.js-schoolUserSelect');
    this.schoolUserValue = this.schoolUserForm.find('.js-schoolUserValue');
    schoolUserValue = this.schoolUserValue;
  },

  initialize: function initialize() {
    this.initializeVariables();
    this.initializeShowHideBehavior();
    this.setSelectSchoolUserHandler();
    this.initializeForm();
  }

});

export default SchoolUserModal;
