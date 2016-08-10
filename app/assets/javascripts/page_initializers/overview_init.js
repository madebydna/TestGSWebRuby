if(gon.pagename == "Overview"){
  $(function () {
    GS.schoolProfiles.initializeSaveThisSchoolButton();
    GS.schoolProfiles.initializeFollowThisSchool();
  });

  GS.schoolProfiles.showSignUpForSchoolModalAfterDelay();
  GS.syncHeight.syncHeights();
  GS.nearbySchools.initialize();

  setTimeout(function() {
    GS.schoolProfiles.showABTestAdsOnlyOnce();
  }, 5000);

};
