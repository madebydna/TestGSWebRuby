$(function() {
  if (gon.pagename == "SearchResultsPage") {
    GS.search.init();
    if (gon.show_ads) {
      GS.ad.interstitial.attachInterstitial();
    }
  }
});