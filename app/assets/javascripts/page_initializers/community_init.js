$(function() {
  if (gon.pagename == "CommunityHomePage") {
    GS.search.autocomplete.searchAutocomplete.init(gon.state_abbr);
    GS.search.schoolSearchForm.placeholderMobile();
    GS.search.schoolSearchForm.checkGooglePlaceholderTranslate(); // all
  }
});
