import configureStore from '../store/appStore';

import Equity from '../components/equity/equity';
import ReviewDistribution from '../components/review_distribution';
import Reviews from '../components/review/reviews';
import NearestHighPerformingSchools from '../components/nearest_high_performing_schools';
import { makeDrawersWithSelector } from '../util/drawer';
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
