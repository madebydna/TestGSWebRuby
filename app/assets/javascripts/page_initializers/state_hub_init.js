$(function() {
  if (gon.pagename && gon.pagename.indexOf("GS:State") >= 0) {
    GS.search.init();
//    GS.search.autocomplete.searchAutocomplete.init();
  }
});