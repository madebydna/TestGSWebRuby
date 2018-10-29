$(function() {
    if (gon.pagename == "SearchResultsPage") {
        GS.search.schoolSearchForm.setupToolTip();
        GS.search.schoolSearchForm.updateFilterState();
        GS.search.schoolSearchForm.setShowFiltersCookieHandler();
        GS.search.assignedSchools.init();
        GS.googleMap.addToInitDependencyCallbacks(GS.util.wrapFunction(GS.search.toggleListMapView.init, this, []));
      //$('[data-toggle="tooltip"]').tooltip({});
      GS.search.results.init();
    }
});
