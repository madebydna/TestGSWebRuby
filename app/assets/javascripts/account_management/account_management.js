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

  var showChangePasswordForm = function(){
    $('.js-change-password-form-container').toggle();
  }

  return {
    init: init,
    showChangePasswordForm: showChangePasswordForm
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
      var hash = {};
      var $self = $(this);
      var id = $self.data('id');
      hash.callback = GS.accountManagement.savedSearch.deleteSuccessful;
      hash.callback_error = GS.accountManagement.savedSearch.deleteFailure;
      hash.href = '/gsr/ajax/saved_search/' + id;
      GS.util.deleteAjaxCall($self, hash);
      return false;
    });
  };

  var deleteSuccessful = function(obj, data, params){
    obj.parents('.js-savedSearch').fadeOut(500, function() { $(this).remove(); })
  };

  var deleteFailure = function(obj, data, params){
    obj.parents('.js-savedSearch').append("<div class='alert alert-error'><a href='#' class='close' data-dismiss='alert'>&times;</a>Currently we are not able to remove the saved search from your list.  Please try again later.</div>");
  };

  return {
    init: init,
    deleteSuccessful: deleteSuccessful,
    deleteFailure: deleteFailure
  }
})();

GS.accountManagement.mySchoolList = (function(){
  var init = function() {
    setDeleteMySchoolListHandler();
  };

  var setDeleteMySchoolListHandler = function() {
    $("a[class^=js-delete-favorite-school-]").on('click', function(){
      var hash = {};
      var $self = $(this);
      hash.callback = GS.accountManagement.mySchoolList.deleteSuccessful;
      hash.callback_error = GS.accountManagement.mySchoolList.deleteFailure;
      hash.href = $self.attr('href');
      GS.util.deleteAjaxCall($self, hash);
      return false;
    });
  };

  var deleteSuccessful = function(obj, data, params){
    var css_selector = ".js-favorite-school-"+params.id;
    $(css_selector).slideUp();
    var numOfVisibleRows = $('.js-schoolSearchResult').parent().filter(function() {
      return $(this).css('display') !== 'none';
    }).length;
    if(numOfVisibleRows == 1){
      $(".js-submitSchoolPYOC").prop("disabled",true);
    }
  };

  var deleteFailure = function(obj, data, params){
    obj.append("<div class='alert alert-error'><a href='#' class='close' data-dismiss='alert'>&times;</a>Currently we are unable to remove this school from your school list.  Please try again later.</div>");
  };

  return {
    init: init,
    deleteSuccessful: deleteSuccessful,
    deleteFailure: deleteFailure
  }
})();



GS.accountManagement.newsFeedUnsubscribe = (function(){
  var init = function() {
    setDeleteNewsFeedUnsubscribeHandler();
  };

  var setDeleteNewsFeedUnsubscribeHandler = function() {
    $("input[class^=js-delete-subscription-]").on('click', function(){
      var hash = {};
      var $self = $(this);
      hash.callback = GS.accountManagement.newsFeedUnsubscribe.deleteSuccessful;
      hash.callback_error = GS.accountManagement.newsFeedUnsubscribe.deleteFailure;
      hash.href = $self.val();
      GS.util.deleteAjaxCall($self, hash);
//      return true;
        return false;

    });
  };

  var deleteSuccessful = function(obj, data, params){
    var css_selector = ".js-delete-subscription-"+params.id;
    $(css_selector).attr('checked', false);
    $(css_selector).addClass("js-add-subscription-"+params.name);
    $(css_selector).removeClass("js-delete-subscription-"+params.id);
  };

  var deleteFailure = function(obj, data, params){
    obj.append("<div class='alert alert-error'><a href='#' class='close' data-dismiss='alert'>&times;</a>Currently we are unable to remove the you from this email list.  Please try again later.</div>");
  };

  return {
    init: init,
    deleteSuccessful: deleteSuccessful,
    deleteFailure: deleteFailure
  }
})();

GS.accountManagement.slideToggleSection = (function(){
    var init = function() {
        slideToggleSections();

    };

    var slideToggleSections = function () {

        $('.js-header-slide-toggle').on('click', function () {
            var openSection = $(this).siblings('div:first');
            var child = $(this).find('.iconx32-college_ready');
            child.toggleClass('i-32-close-arrow-head i-32-open-arrow-head');

            openSection.slideToggle();
        });
    }

    return {
        init: init
    }
})();

GS.accountManagement.displayHometownChooser = (function(){
    var init = function(){
        displayHometownChoosers();
    };

    var displayHometownChoosers = function() {

        $('.js-change-hometown-link').on('click', function () {
            $('.js-hometown-chooser-display').removeClass('dn');
            $('.js-hometown-chosen').addClass('dn');
        });
    }
    return {
        init: init
    }
})();

GS.accountManagement.newsFeedSubscribe= (function(){
    var init = function() {
        setAddNewsFeedSubscribeHandler();
    };

    var setAddNewsFeedSubscribeHandler = function() {
        $("input[class^=js-add-subscription-]").on('click', function(){
            var hash = {};
            var $self = $(this);
            hash.callback = GS.accountManagement.newsFeedSubscribe.addSuccessful;
            hash.callback_error = GS.accountManagement.newsFeedSubscribe.addFailure;
            var list = $self.attr("name");
            if (list !== undefined) {

                $.ajax({
                    type: 'GET',
                    url: "/gsr/user/account_subscriptions/",
                    data: {list: list},
                    dataType: 'json',
                    async: true
                }).done(function (data) {
                    var css_selector = ".js-add-subscription-"+data[list];
                    $(css_selector).attr('checked', true);
                    $(css_selector).removeClass("js-add-subscription-"+data[list]);
//                        $(css_selector).removeClass("js-delete-subscription-"+params.id);
                });
            }
            return true;
            //return false;

        });
    };

    var addSuccessful = function(obj, data, params){
        var css_selector = ".js-delete-subscription-"+params.id;
        $(css_selector).attr('checked', false);
        $(css_selector).addClass("js-add-subscription-"+params.name);
        $(css_selector).removeClass("js-delete-subscription-"+params.id);
    };

    var addFailure = function(obj, data, params){
        obj.append("<div class='alert alert-error'><a href='#' class='close' data-dismiss='alert'>&times;</a>Currently we are unable to add you to this email list.  Please try again later.</div>");
    };

    return {
        init: init,
        addSuccessful: addSuccessful,
        addFailure: addFailure
    }
})();

GS.accountManagement.addGradeLevel= (function(){
    var init = function() {
        addGradeLevelHandler();
    };

    var addGradeLevelHandler = function() {
        $(".js-select-grade-level").on('click', 'input[class^=js-add-grade-level-]', function(){
            var hash = {};
            var $self = $(this);
            var gradeValue = $self.attr("name");
            if (gradeValue !== undefined) {

                $.ajax({
                    type: 'GET',
                    url: "/gsr/user/save_grade_selection",
                    data: {grade: gradeValue},
                    dataType: 'json',
                    async: true
                }).done(function (data) {
                    var css_selector = ".js-add-grade-level-"+data['grade_level'];

                    $(css_selector).addClass("js-delete-grade-level-"+data['grade_level']);
                    $(css_selector).removeClass("js-add-grade-level-"+data['grade_level']);

                });
            }
            return true;

        });
    };


    return {
        init: init
    }
})();

GS.accountManagement.deleteGradeLevel= (function(){
    var init = function() {
        deleteGradeLevelHandler();
    };

    var deleteGradeLevelHandler = function() {
        $(".js-select-grade-level").on('click','input[class^=js-delete-grade-level-]', function(){
            var $self = $(this);
            var gradeValue = $self.attr("name");
            if (gradeValue !== undefined) {

                $.ajax({
                    type: 'GET',
                    url: "/gsr/user/delete_grade_selection",
                    data: {grade: gradeValue},
                    dataType: 'json',
                    async: true
                }).done(function (data) {
                    var css_selector = ".js-delete-grade-level-"+data['grade_level'];

                    $(css_selector).addClass("js-add-grade-level-"+data['grade_level']);
                    $(css_selector).removeClass("js-delete-grade-level-"+data['grade_level']);

                });
            }
            return true;

        });
    };


    return {
        init: init
    }
})();





