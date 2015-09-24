var GS = GS || {};

GS.modal = GS.modal || {};

GS.modal.manager = GS.modal.manager || (function ($) {
    var GLOBAL_MODAL_CONTAINER_SELECTOR = '.js-modal-container';

    var insertModalIntoDom = function (modal) {
        $(GLOBAL_MODAL_CONTAINER_SELECTOR).append(modal);
    };

    var displayModal = function (modalObject, options) {
        options = options || {};
        var modalCssClass = options.modalCssClass || modalObject.getModalCssClass();
        var url = modalObject.url();
        url = GS.uri.Uri.addQueryParamToUrl('modal_css_class', modalCssClass, url);
        url = GS.I18n.preserveLanguageParam(url);
        return $.ajax({
            method: 'GET',
            url: url
        })
            .done(function (response) {
                insertModalIntoDom(response);
                modalObject.initialize();
                modalObject.show();
            })
            .fail(function (response) {
// The caller can specify what to do if the model fails.
            });
    };

    return  {
        displayModal: displayModal
    };

})(jQuery);

GS.modal.signUpForSchool = GS.modal.signUpForSchool || (function ($) {
    var MODAL_CLASS = 'signupModal';
    var MODAL_SELECTOR = '.' + MODAL_CLASS;
    var SIGNUP_SCHOOL_SELECTOR = '#signup-school-form';
    var FAVORITE_SCHOOL_FORM_SELECTOR = '#new_favorite_school_ajax';
    var SAVE_THIS_SCHOOL_FORM_SELECTOR = '.js-save-this-school-form-ajax';
    var MODAL_URL = '/gsr/modals/signup_and_follow_school_modal';
    var SUBMIT_BUTTON_SELECTOR = '.js-modal-signup-button';
    var SUCCESS_MESSAGE_TIME = 2000;
    var ERROR_CONTAINER_SELECTOR = '.js-signup-email-errors';
    var SIGNUP_SUCCESS_MESSAGE_SELECTOR = '.js-signup-success';

    var $getModal = function() {
      return $(MODAL_SELECTOR);
    };

    var $getSubmitButton = function() {
      return $getModal().find(SUBMIT_BUTTON_SELECTOR);
    };

    var $getSignupSchoolForm = function() {
      return $(SIGNUP_SCHOOL_SELECTOR);
    };

    var $getFavoriteSchoolForm = function() {
      return $(FAVORITE_SCHOOL_FORM_SELECTOR);
    };

    var $getSaveThisSchoolForm = function() {
      return $(SAVE_THIS_SCHOOL_FORM_SELECTOR);
    };

    var initializeSignupForm = function () {
      var $submitButton = $getSubmitButton();
        $getSignupSchoolForm().on('ajax:success', function (e, data, status, xhr) {
            $submitButton.hide();
            if( shouldSignUpForSponsor() ) {
              GS.subscription.sponsorsSignUp();
            }
            $getSaveThisSchoolForm().submit();
        }).on('ajax:error', function (e, xhr, status, error) {
            $submitButton.show();
            showError(xhr.responseJSON);
        });
    };

    var initializeSaveSchoolForm = function () {
      var $submitButton = $getSubmitButton();
        $getSignupSchoolForm().parsley();
        $getFavoriteSchoolForm().on('ajax:success', function (e, data, status, xhr) {
            $submitButton.prop('disabled', true);
            $submitButton.show();
            $(SIGNUP_SUCCESS_MESSAGE_SELECTOR).slideToggle();
            setTimeout(function () {
                hideModal();
            }, SUCCESS_MESSAGE_TIME)
        }).on('ajax:error', function (e, xhr, status, error) {
            $submitButton.show();
            showError(xhr.responseJSON);
        });
    };

    var showError = function (responseJSON) {
        //var errorMessage = responseJSON['error'];
        var errorMessage = 'Please <a href="/gsr/login/">log in or register your email</a> to begin tracking your favorite schools.';
        $(ERROR_CONTAINER_SELECTOR).html(errorMessage);
    };

    var show = function () {
        $getModal().modal('show');
    };

    var hideModal = function () {
        $getModal().modal('hide');
    };

    var initialize = function () {
        initializeSaveSchoolForm();
        initializeSignupForm();
    };

    var shouldSignUpForSponsor = function () {
        return $('#sponsors_list').prop('checked');
    };

    var getModalCssClass = function () {
        return MODAL_CLASS;
    };

    var url = function () {
        return MODAL_URL;
    };

    return {
        initialize: initialize,
        show: show,
        url: url,
        getModalCssClass: getModalCssClass
    };

})(jQuery);

