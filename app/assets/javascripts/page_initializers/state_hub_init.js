$(function() {
  if (!gon.pagename.empty && gon.pagename.indexOf("GS:State") >= 0) {
    GS.search.init();
  }
});