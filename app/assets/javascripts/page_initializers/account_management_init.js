if(gon.pagename == "Account management"){
  $(function () {
    GS.accountManagement.changePassword.init();
    GS.accountManagement.PYOC.init();
    GS.accountManagement.savedSearch.init();

//    this stops quick clicking on the remove button as it is gone after first click
    $("a[class^=js-delete-favorite-school-]").on('click', function(){
      $(this).remove();
    });
  });
}