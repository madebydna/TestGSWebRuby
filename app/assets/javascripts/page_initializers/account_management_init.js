if(gon.pagename == "Account management"){
  $(function () {
    GS.select.school.attachAutocomplete();
    GS.accountManagement.changePassword.init();
  });
}