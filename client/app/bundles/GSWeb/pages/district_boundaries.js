import configureStore from '../store/appStore';

import DistrictBoundaries from '../react_components/district_boundaries/district_boundaries';
import ConnectedDistrictBoundaries from '../react_components/district_boundaries/connected_district_boundaries.jsx';
import { getValueOfQueryParam } from '../util/uri';

window.store = configureStore({
  districtBoundaries: {
    schools: {},
    districts: {},
    school: null,
    district: null,
    lat: getValueOfQueryParam('lat'),
    lon: getValueOfQueryParam('lon'),
    state: getValueOfQueryParam('state'),
    stateId: getValueOfQueryParam('stateId')
  }
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
