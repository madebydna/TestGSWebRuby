$(function() {

  GS.handlebars.registerPartials();
  GS.handlebars.registerHelpers();

  // When search bar added to universal nav, was required to init autocomplete on all pages
  // State specific pages have gon.state_abbr state and will initialize autocomplete with state
  // if state abbreviation is NOT set will init autocomplete without state.
  // All page specific initializing of autocomplete was removed
  //
  if (gon.state_abbr) {
    GS.search.autocomplete.searchAutocomplete.init(gon.state_abbr);
  }
  else {
    GS.search.autocomplete.searchAutocomplete.init();
  }
});
