if (gon.pagename == "Details") {
    $(function () {
        GS.schoolProfiles.initializeSaveThisSchoolButton();
        GS.schoolProfiles.initializeFollowThisSchool();
        GS.nearbySchools.initialize();
        $('body').scrollspy({ target:'.spy-nav' })
    });

    GS.schoolProfiles.showSignUpForSchoolModalAfterDelay();
}
