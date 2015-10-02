$(function() {
    if (gon.pagename == "GS:OSP:LandingPage") {
        var ospSchoolPicker = GS.schoolPicker.navigateToUrl.builder(GS.schoolPicker.ospLandingPage);
        GS.schoolPicker.initSchoolpickerAndAutocomplete( ospSchoolPicker.onAutocompleteSchoolSelectCallback, ospSchoolPicker.customSchoolSelectCallback)
    }
});
