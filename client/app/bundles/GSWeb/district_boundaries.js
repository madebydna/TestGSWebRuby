import ReactOnRails from 'react-on-rails';
import configureStore from './store/appStore';
import DistrictBoundaries from './react_components/district_boundaries/district_boundaries';
import DistrictBoundariesLegend from './react_components/district_boundaries/district_boundaries_legend';
import ConnectedDistrictBoundaries from './react_components/district_boundaries/connected_district_boundaries.jsx';
import { getValueOfQueryParam } from './util/uri';

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
    schoolTypes: [],
    loading: false
  }
});

ReactOnRails.register({
  DistrictBoundaries,
  ConnectedDistrictBoundaries,
  DistrictBoundariesLegend
});

$(function() {
  ReactOnRails.reactOnRailsPageLoaded();
});






