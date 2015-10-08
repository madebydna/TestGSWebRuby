if(gon.pagename == "Overview"){
  $(function () {
    GS.schoolProfiles.initializeSaveThisSchoolButton();
    if($("#galleria").get(0)){
        Galleria.run('#galleria');
    }
  });

  GS.schoolProfiles.showSignUpForSchoolModalAfterDelay();

};
