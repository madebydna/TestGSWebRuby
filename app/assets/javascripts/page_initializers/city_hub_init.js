$(function() {
  if (gon.pagename && gon.pagename.indexOf("GS:City") >= 0) {
      GS.googleMap.addToInitDependencyCallbacks(GS.util.wrapFunction(GS.search.schoolSearchForm.init, this, []));
      GS.search.schoolSearchForm.setupTabs(); // switch by loc by name
      GS.search.autocomplete.searchAutocomplete.init(gon.state_abbr);
  }
});