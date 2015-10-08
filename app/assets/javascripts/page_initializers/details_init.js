if (gon.pagename == "Details") {
    $(function () {
        GS.schoolProfiles.initializeSaveThisSchoolButton();
        $('body').scrollspy({ target:'.spy-nav' })
    });

    GS.schoolProfiles.showSignUpForSchoolModalAfterDelay();
}