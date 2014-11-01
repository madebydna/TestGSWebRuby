$(function() {
    if (gon.pagename == "SearchResultsPage") {
        GS.search.init();
        GS.googleMap.addToGetScriptCallback(GS.search.toggleListMapView.init);
        GS.ad.interstitial.attachInterstitial();
    }
});