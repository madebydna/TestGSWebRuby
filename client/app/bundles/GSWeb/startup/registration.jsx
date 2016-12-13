import ReactOnRails from 'react-on-rails';

import GSWebApp from './GSWebApp';
import Equity from '../components/equity/equity';
import Reviews from '../components/review/reviews';
import NearestHighPerformingSchools from '../components/nearest_high_performing_schools';

// This is how react_on_rails can see the GSWeb in the browser.
ReactOnRails.register({
  GSWebApp,
  Equity,
  Reviews,
  NearestHighPerformingSchools
});
