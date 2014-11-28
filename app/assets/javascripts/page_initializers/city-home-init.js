$(function() {
  if (gon.pagename == 'GS:City:Home') {
    var initMap = function() {
      var elemMapCanvas = $('#js-map-canvas');
      GS.googleMap.setHeightForMap(300);
      elemMapCanvas.show('fast', GS.googleMap.initAndShowMap);
    };
    GS.googleMap.setAdditionalZoom(2);
    GS.googleMap.addToInitDependencyCallbacks(
      GS.util.wrapFunction(
        initMap, this, []
      )
    );
    GS.ad.interstitial.attachInterstitial();
  }
});