import configureStore from '../store/appStore';

import DistrictBoundaries from '../react_components/district_boundaries/district_boundaries';
import ConnectedDistrictBoundaries from '../react_components/district_boundaries/connected_district_boundaries.jsx';

window.store = configureStore({
});

ReactOnRails.register({
  DistrictBoundaries,
  ConnectedDistrictBoundaries
});

$(function() {
});

// var initMap = function() {
//   var elemMapCanvas = $('#js-map-canvas');
//   GS.googleMap.setHeightForMap(300);
//   elemMapCanvas.show('fast', GS.googleMap.initAndShowMap);
// };
