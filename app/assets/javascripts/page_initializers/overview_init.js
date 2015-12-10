if(gon.pagename == "Overview"){
  $(function () {
    GS.schoolProfiles.initializeSaveThisSchoolButton();
    GS.schoolProfiles.initializeFollowThisSchool();

    setTimeout(GS.schoolProfiles.showReviewsSectionAdOnlyOnce, 5000);
  });

  GS.schoolProfiles.showSignUpForSchoolModalAfterDelay();
  GS.syncHeight.syncHeights();
  GS.nearbySchools.initialize();

};
