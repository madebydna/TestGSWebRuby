$(function() {
  if (gon.pagename && gon.pagename.indexOf("GS:State") >= 0) {
      GS.search.schoolSearchForm.setupTabs(); // switch by loc by name
  }
});