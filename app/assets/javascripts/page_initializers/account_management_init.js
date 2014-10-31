if(gon.pagename == "Account management"){
  $(function () {
    GS.accountManagement.changePassword.init();
    GS.accountManagement.PYOC.init();
    GS.accountManagement.savedSearch.init();
    GS.accountManagement.mySchoolList.init();
    GS.accountManagement.newsFeedUnsubscribe.init();

//    this stops quick clicking on the remove button as it is gone after first click
//    $("a[class^=js-delete-favorite-school-]").on('click', function(){
//      var $self = $(this);
//      $self.hide();
//      GS.util.deleteAjaxCall($self);
//      return false;
//    });
  });
}