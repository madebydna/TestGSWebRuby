$(function() {
  if (gon.pagename == "State_Home_Standard") {
    GS.search.init();
    GS.search.autocomplete.searchAutocomplete.init(gon.state_abbr);
  }
});