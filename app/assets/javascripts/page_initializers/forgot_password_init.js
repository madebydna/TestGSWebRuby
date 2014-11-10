if(gon.pagename == "Forgot Password"){
  $(function () {

    $('.js-send-forgot-password-email').parsley({
      excluded: '', // don't exclude hidden fields, since we want to validate the stars
      successClass: 'has-success',
      errorClass: 'has-error',
      errors: {
        errorsWrapper: '<div></div>',
        errorElem: '<div></div>'
      }
    });

    $('.js-send-forgot-password-email').parsley('addListener', {
      onFieldError: function (elem) {
        elem.closest('.form-group').addClass('has-error');
      },
      onFieldSuccess: function (elem) {
        elem.closest('.form-group').removeClass('has-error');
      }
    });

  });
}