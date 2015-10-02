$(function () {
  if(gon.pagename == "Account management"){

    GS.accountManagement.changePassword.init();
    GS.accountManagement.PYOC.init();
    GS.accountManagement.savedSearch.init();
    GS.accountManagement.mySchoolList.init();
    GS.accountManagement.newsFeedUnsubscribe.init();
    GS.accountManagement.newsFeedSubscribe.init();
    GS.search.autocomplete.cityAutocomplete.init(gon.state_locale_abbr);
    GS.accountManagement.slideToggleSection.init();
    GS.accountManagement.displayHometownChooser.init();
    GS.search.autocomplete.cityAutocomplete.setUserAccountStatePickerHandler();
    GS.accountManagement.addGradeLevel.init();
    GS.accountManagement.deleteGradeLevel.init();



    var url_hash = window.location.hash;
    if(url_hash !== ''){
      var hash = url_hash.substring(url_hash.indexOf("#")+1);
      if(hash === 'change-password'){
        GS.accountManagement.changePassword.showChangePasswordForm();
      }
    }
  }
});