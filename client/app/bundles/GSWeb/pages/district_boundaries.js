import configureStore from '../store/appStore';

import DistrictBoundaries from '../react_components/district_boundaries/district_boundaries';

window.store = configureStore({
});

ReactOnRails.register({
  DistrictBoundaries
});

$(function() {
});

// var initMap = function() {
//   var elemMapCanvas = $('#js-map-canvas');
//   GS.googleMap.setHeightForMap(300);
//   elemMapCanvas.show('fast', GS.googleMap.initAndShowMap);
// };
