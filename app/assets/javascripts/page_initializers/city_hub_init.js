$(function() {
  if (gon.pagename && gon.pagename.indexOf("GS:City") >= 0) {
    GS.search.init();
//    GS.search.autocomplete.searchAutocomplete.init();
  }
});