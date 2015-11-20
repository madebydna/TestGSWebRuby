$(function() {
  if (gon.pagename == "CommunityHomePage") {
    GS.googleMap.addToInitDependencyCallbacks(GS.util.wrapFunction(GS.search.schoolSearchForm.init, this, []));
    GS.search.autocomplete.searchAutocomplete.init(gon.state_abbr);
  }
});
