$(function() {
  if (gon.pagename && gon.pagename.indexOf("GS:City") >= 0) {
      GS.search.schoolSearchForm.setupTabs(); // switch by loc by name
      GS.search.autocomplete.searchAutocomplete.init(gon.state_abbr);
  }
});