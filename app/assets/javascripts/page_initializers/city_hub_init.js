$(function() {
  if (!gon.pagename.empty && gon.pagename.indexOf("GS:City") >= 0) {
    GS.search.init();
  }
});