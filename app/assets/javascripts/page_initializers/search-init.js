$(function() {
  if (gon.pagename == "SearchResultsPage") {
    GS.search.init();
    GS.ad.interstitial.attachInterstitial();
  }
});