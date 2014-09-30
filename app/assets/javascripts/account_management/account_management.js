var GS = GS || {}
GS.accountManagement = GS.accountManagement || {}

GS.accountManagement.changePassword = (function(){
  var contentSelector = ".js-change-password-form-content";
  var formSelector = ".js-change-password-form";
  var passwordSelector = formSelector + " input[name=password]"
  var errorContainerSelector = '.js-change-password-form-error-container'

  var init = function() {
    $(formSelector).on('submit', submitHandler);

    $('.js-submitSchoolPYOC').on('click', submitPyocForm);
  };

  var showError = function(message) {
    $errorContainer = $(errorContainerSelector); 
    $errorContainer.show();
    $errorContainer.html(message);
  };

  var submitPyocForm = function() {

  };

  var submitHandler = function() {
    var $form = $(formSelector);
    var action = $form.attr('action');
    var formData = $form.serialize();
    $(errorContainerSelector).hide();

    $.post(action,
      formData
    ).done(function(response) {
      if(response['success'] === true){
        $(contentSelector).html(response.message)
      } else {
        showError(response.message);
      }
    }).fail(function(response) {
      showError('An error occurred when processing your request.');
    })

    return false;
  };

  return {
    init: init
  };
})();

GS.accountManagement.PYOC = (function(){
  var init = function() {
    $('.js-submitSchoolPYOC').on('click', submitPyocForm);
  };

  var submitPyocForm = function() {
    var submitForm = $(".js-printSchoolChooserSubmit");
    var state = [];
    var schoolID = [];
    var count = 0;
    //    create lists
    $('.js-schoolSearchResult').each(function() {
      var $school = $(this);
      var schoolId = $school.data('schoolid');
      var schoolState = $school.data('schoolstate');
      state.push(schoolState);
      schoolID.push(schoolId);
      count++;
    });
    if(count > 0){
      submitForm.children('.js-chooserStates').val(state.join(','));
      submitForm.children('.js-chooserSchoolIds').val(schoolID.join(','));
      submitForm.submit();
    }
  };

  return {
    init: init
  };
})();
