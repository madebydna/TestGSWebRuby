import configureStore from '../store/appStore';

import Equity from '../react_components/equity/equity';
import ReviewDistribution from '../react_components/review_distribution';
import Reviews from '../react_components/review/reviews';
import NearestHighPerformingSchools from '../react_components/nearest_high_performing_schools';
import { makeDrawersWithSelector } from '../components/drawer';
import { generateEthnicityChart } from '../components/ethnicity_pie_chart';

window.store = configureStore({
  school: gon.school
});

ReactOnRails.register({
  Equity,
  ReviewDistribution,
  Reviews,
  NearestHighPerformingSchools
});

ReactOnRails.reactOnRailsPageLoaded();

$(function() {
  generateEthnicityChart(gon.ethnicity);
  makeDrawersWithSelector($('.js-drawer'));
});
