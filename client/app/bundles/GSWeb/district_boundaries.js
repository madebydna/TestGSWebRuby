import ReactOnRails from 'react-on-rails';
import configureStore from './store/appStore';
import DistrictBoundaries from './react_components/district_boundaries/district_boundaries';
import DistrictBoundariesLegend from './react_components/district_boundaries/district_boundaries_legend';
import ConnectedDistrictBoundaries from './react_components/district_boundaries/connected_district_boundaries.jsx';
import { getValueOfQueryParam } from './util/uri';
import SearchBox from 'react_components/search_box';
import withViewportSize from 'react_components/with_viewport_size';
import commonPageInit from './common';

const SearchBoxWrapper = withViewportSize({ propName: 'size' })(SearchBox);

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
    districtId: getValueOfQueryParam('districtId'),
    nearbyDistrictsRadius: 50,
    level: getValueOfQueryParam('level') || 'e',
    schoolTypes: [],
    loading: false
  }
});

ReactOnRails.register({
  DistrictBoundaries,
  ConnectedDistrictBoundaries,
  DistrictBoundariesLegend,
  SearchBoxWrapper
});

$(commonPageInit);