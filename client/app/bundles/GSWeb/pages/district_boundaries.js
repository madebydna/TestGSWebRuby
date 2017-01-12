import configureStore from '../store/appStore';

import DistrictBoundaries from '../react_components/district_boundaries/district_boundaries';

window.store = configureStore({
});

ReactOnRails.register({
  DistrictBoundaries
});


$(function() {

});

