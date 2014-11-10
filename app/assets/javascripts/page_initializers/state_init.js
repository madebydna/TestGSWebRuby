$(function() {
  if (gon.pagename == "GS:State:Home") {
    GS.googleMap.addToInitDependencyCallbacks(GS.util.wrapFunction(GS.search.schoolSearchForm.init, this, []));
    GS.search.autocomplete.searchAutocomplete.init(gon.state_abbr);
    GS.ad.interstitial.attachInterstitial();
  }
});