if(gon.pagename == "Account management"){
  $(function () {
    GS.accountManagement.changePassword.init();
    GS.accountManagement.PYOC.init();
    GS.accountManagement.savedSearch.init();
    GS.accountManagement.mySchoolList.init();
    GS.accountManagement.newsFeedUnsubscribe.init();
    GS.search.autocomplete.cityAutocomplete.init(gon.state_locale_abbr);
    GS.accountManagement.slideToggleSection.init();
    GS.search.autocomplete.cityAutocomplete.setUserAccountStatePickerHandler();

      

    var url_hash = window.location.hash;
    if(url_hash !== ''){
      var hash = url_hash.substring(url_hash.indexOf("#")+1);
      if(hash === 'change-password'){
        GS.accountManagement.changePassword.showChangePasswordForm();
      }
    }

  });
}