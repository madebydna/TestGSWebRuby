if(gon.pagename == "Overview"){
  $(function () {
    GS.schoolProfiles.initializeSaveThisSchoolButton();
  });

  GS.schoolProfiles.showSignUpForSchoolModalAfterDelay();
  GS.syncHeight.syncHeights();

};