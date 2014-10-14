var GS = GS || {}
GS.accountManagement = GS.accountManagement || {}

GS.accountManagement.schoolListRemovedSchool = (function(school_id){
  var css_selector = ".js-favorite-school-"+school_id;
  $(css_selector).slideUp();
  var numOfVisibleRows = $('.js-schoolSearchResult').parent().filter(function() {
    return $(this).css('display') !== 'none';
  }).length;
  if(numOfVisibleRows == 1){
    $(".js-submitSchoolPYOC").prop("disabled",true);
  }
});

GS.accountManagement.changePassword = (function(){
  var contentSelector = ".js-change-password-form-content";
  var formSelector = ".js-change-password-form";
  var passwordSelector = formSelector + " input[name=password]"
  var errorContainerSelector = '.js-change-password-form-error-container'

  var init = function() {
    $(formSelector).on('submit', submitHandler);
  };

  var showError = function(message) {
    $errorContainer = $(errorContainerSelector); 
    $errorContainer.show();
    $errorContainer.html(message);
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

GS.accountManagement.savedSearch = (function(){
  var init = function() {
    setDeleteSavedSearchHandler();
  };

  var setDeleteSavedSearchHandler = function() {
    $('.js-savedSearches').on('click', '.js-savedSearchDelete', function() {
      deleteSavedSearch.call(this);
      return false;
    });
  };

  var deleteSavedSearch = function() {
    $self = $(this);
    var id = $self.data('id');

    if ( id !== undefined && typeof id == 'number' ) {

      $deferred = $.ajax({
        url: '/gsr/ajax/saved_search/' + id,
        type: 'DELETE'
      });

      $deferred.done(function(response) {
        var error = response['error'];
        if (typeof error === 'string' && error !== '' ) {
          alert(response['error']);
        } else {
          $self.parents('.js-savedSearch').fadeOut(500, function() { $(this).remove(); })
        }
      });

      $deferred.fail(function(response){
        alert('Sorry but wen\'t wrong. Please try again later');
      });
    }
  };

  return {
    init: init
  }
})();

if (gon.pagename === 'Account management') {
  $(document).ready(function () {
      GS.accountManagement.savedSearch.init();
  });
}
