import configureStore from '../store/appStore';

import DistrictBoundaries, { DistrictBoundariesLegend } from '../react_components/district_boundaries/district_boundaries';
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
    schoolId: getValueOfQueryParam('schoolId'),
    nearbyDistrictsRadius: 50,
    level: 'e',
    schoolTypes: []
  }
});

ReactOnRails.register({
  DistrictBoundaries,
  ConnectedDistrictBoundaries,
  DistrictBoundariesLegend
});

$(function() {
});

// var initMap = function() {
//   var elemMapCanvas = $('#js-map-canvas');
//   GS.googleMap.setHeightForMap(300);
//   elemMapCanvas.show('fast', GS.googleMap.initAndShowMap);
// };
