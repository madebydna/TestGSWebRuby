$(function() {
  if (!gon.pagename.empty && gon.pagename.indexOf("GS:City") >= 0) {
    GS.search.init();
    $('.js-clear-local-cookies-link').each(function() {
      $(this).click(GS.hubs.clearLocalUserCookies);
    });
  }
});