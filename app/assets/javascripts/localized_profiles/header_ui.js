GS.profile = GS.profile || {};

GS.profile.ui = GS.profile.ui || (function() {

    // take response from ajax registration / login and update the UI with data
    var updateWithUserData = function (userId, email, firstName, numberMSLItems) {

    };

    var isProfilePage = function() {
        return ['Overview','Quality','Details','Reviews'].indexOf(gon.pagename) >= 0
    };

    var showBackToCompareLink = function () {
        if (GS.localStorage.getItem('comparingSchools')) {
            var state = GS.stateAbbreviationFromUrl();
            var schoolId = GS.schoolIdFromUrl();
            GS.compare.schoolsList.init();
            if (state === GS.compare.schoolsList.getState()) {
                if (GS.compare.schoolsList.listContainsSchoolId(schoolId)) {
                    var backToCompare = $('.js-backToCompare');
                    backToCompare.attr('href', GS.compare.schoolsList.buildCompareURL());
                    backToCompare.removeClass('dn');
                }
            }
        }
    };

    return {
        updateWithUserData: updateWithUserData,
        isProfilePage: isProfilePage,
        showBackToCompareLink: showBackToCompareLink
    }

})();

if (GS.profile.ui.isProfilePage()) {
    $(document).ready(function () {
        GS.profile.ui.showBackToCompareLink();
    });
}