GS.modal = GS.modal || {};

GS.modal.manager = GS.modal.intializer || (function ($) {
    var GLOBAL_MODAL_CONTAINER_SELECTOR = '.js-modal-container';

    var insertModalIntoDom = function (modal) {
        $(GLOBAL_MODAL_CONTAINER_SELECTOR).append(modal);
    };

    var displayModal = function (modalObject, options) {
        options = options || {};
        var modalCssClass = options.modalCssClass || modalObject.getModalCssClass();
        var query_string = '?modal_css_class=' + modalCssClass;
        var url = modalObject.url() + query_string;
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
    var MODAL_SELECTOR = 'signupModal';
    var SIGNUP_SCHOOL_SELECTOR = '#signup-school-form';
    var FAVORITE_SCHOOL_FORM_SELECTOR = '#new_favorite_school_ajax';
    var SAVE_THIS_SCHOOL_FORM_SELECTOR = '.js-save-this-school-form-ajax';
    var MODAL_URL = '/gsr/modals/signup_and_follow_school_modal';
    var SUBMIT_BUTTON_SELECTOR = '.js-modal-signup-button';
    var SUCCESS_MESSAGE_TIME = 2000;
    var ERROR_CONTAINER_SELECTOR = '.js-signup-email-errors';
    var SIGNUP_SUCCESS_MESSAGE_SELECTOR = '.js-signup-success';

    var initializeSignupForm = function () {
        $(SIGNUP_SCHOOL_SELECTOR).on('ajax:success', function (e, data, status, xhr) {
            $(SAVE_THIS_SCHOOL_FORM_SELECTOR).submit();
        }).on('ajax:error', function (e, xhr, status, error) {
            showError(xhr.responseJSON);
        });
    };

    var initializeSaveSchoolForm = function () {
        $(SIGNUP_SCHOOL_SELECTOR).parsley();
        $(FAVORITE_SCHOOL_FORM_SELECTOR).on('ajax:success', function (e, data, status, xhr) {
            $(SUBMIT_BUTTON_SELECTOR).prop('disabled', true);
            $(SIGNUP_SUCCESS_MESSAGE_SELECTOR).slideToggle();
            setTimeout(function () {
                hideModal();
            }, SUCCESS_MESSAGE_TIME)
        }).on('ajax:error', function (e, xhr, status, error) {
            showError(xhr.responseJSON);
        });
    };

    var showError = function (responseJSON) {
        var errorMessage = responseJSON['error'];
        $(ERROR_CONTAINER_SELECTOR).html(errorMessage);
    };

    var show = function () {
        $('.' + MODAL_SELECTOR).modal('show');
    };

    var hideModal = function () {
        $('.' + MODAL_SELECTOR).modal('hide');
    };

    var initialize = function () {
        initializeSaveSchoolForm();
        initializeSignupForm();
    };

    var getModalCssClass = function () {
        return MODAL_SELECTOR;
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
