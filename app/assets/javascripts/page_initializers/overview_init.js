if(gon.pagename == "Overview"){
  $(function () {
    GS.schoolProfiles.initializeSaveThisSchoolButton();
    GS.schoolProfiles.initializeFollowThisSchool();
  });

  GS.schoolProfiles.showSignUpForSchoolModalAfterDelay();
  GS.syncHeight.syncHeights();
  GS.nearbySchools.initialize();

  googletag.cmd.push(function () {
    GS.schoolProfiles.showDetailsOverviewSection();
  });
};
