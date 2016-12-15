import ReactOnRails from 'react-on-rails';

import configureStore from './store/appStore';

import Equity from './components/equity/equity';
import Reviews from './components/review/reviews';
import NearestHighPerformingSchools from './components/nearest_high_performing_schools';

window.store = configureStore({
  school: gon.school
});

ReactOnRails.register({
  Equity,
  Reviews,
  NearestHighPerformingSchools
});

ReactOnRails.reactOnRailsPageLoaded();
