$(function() {
  if (gon.pagename == "Write a school review | GreatSchools") {
      var reviewChooserSchoolPicker = GS.schoolPicker.navigateToUrl.builder(GS.schoolPicker.reviewsChooser);
      GS.schoolPicker.initSchoolpickerAndAutocomplete(reviewChooserSchoolPicker.onAutocompleteSchoolSelectCallback, reviewChooserSchoolPicker.customSchoolSelectCallback);
  }
});

