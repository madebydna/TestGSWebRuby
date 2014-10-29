$(function() {
  if (gon.pagename == "GS:State:Home") {
    GS.search.init();
    GS.search.autocomplete.searchAutocomplete.init(gon.state_abbr);
    GS.ad.interstitial.attachInterstitial();
  }
});