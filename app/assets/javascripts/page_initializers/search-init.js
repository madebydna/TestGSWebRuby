$(function() {
    if (gon.pagename == "SearchResultsPage") {
        GS.search.schoolSearchForm.setShowFiltersCookieHandler();
        GS.search.schoolSearchForm.showFiltersMenuOnLoad();
        GS.search.assignedSchools.init();
        GS.googleMap.addToInitDependencyCallbacks(GS.util.wrapFunction(GS.search.toggleListMapView.init, this, []));
        GS.ad.interstitial.attachInterstitial();
    }
});