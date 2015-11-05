if (gon.pagename == "Details") {
    $(function () {
        GS.schoolProfiles.initializeSaveThisSchoolButton();
        GS.schoolProfiles.initializeFollowThisSchool();
        $('body').scrollspy({ target:'.spy-nav' })
    });

    GS.schoolProfiles.showSignUpForSchoolModalAfterDelay();
}
