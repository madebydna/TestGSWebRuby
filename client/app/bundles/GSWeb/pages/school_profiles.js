import configureStore from '../store/appStore';

import SchoolProfileComponent from '../react_components/equity/school_profile_component';
import ReviewDistribution from '../react_components/review_distribution';
import Reviews from '../react_components/review/reviews';
import NearestHighPerformingSchools from '../react_components/nearest_high_performing_schools';
import Courses from '../react_components/courses';
import { makeDrawersWithSelector } from '../components/drawer';
import { generateEthnicityChart } from '../components/ethnicity_pie_chart';
import { fixToTopWhenBelowY } from '../util/fix_to_top_when_below_y';
import * as tooltips from '../util/tooltip';
import { generateSubgroupPieCharts } from '../components/subgroup_charts';
import * as stickyCTA from '../components/school_profile_sticky_cta';
import { viewport } from '../util/viewport';
import * as remodal from '../util/remodal';
import PrivateSchoolInfo from '../react_components/private_school_info';
import Toggle from '../components/toggle';
import HomesAndRentals from '../react_components/homes_and_rentals';

window.store = configureStore({
  school: gon.school
});

ReactOnRails.register({
  SchoolProfileComponent,
  ReviewDistribution,
  Reviews,
  NearestHighPerformingSchools,
  Courses,
  PrivateSchoolInfo,
  HomesAndRentals
});

$(function() {
  (function() {
    var toggle = _.assign(new Toggle($('#hero').find('.school-info')));
    toggle.effect = "slideToggle";
    toggle.addCallback(
        toggle.updateButtonTextCallback(GS.I18n.t('show_less'), GS.I18n.t('show_more'))
    );
    toggle.init().add_onclick();
  })();
  generateEthnicityChart(gon.ethnicity);
  makeDrawersWithSelector($('.js-drawer'));
  tooltips.initialize();
  remodal.init();
  generateSubgroupPieCharts();
  stickyCTA.init();

  $('.rating-container__title').each(function() {
    var $elem = $(this);
    var minWidth = 1200;

    fixToTopWhenBelowY(
      $elem,
      function($elem){
        return $elem.parent().offset().top - 20;
      },
      function($elem){
        return $elem.parent().offset().top + $elem.parent().parent().parent().height() - 50 - $elem.height();
      },
      function() {
        return viewport().width >= minWidth;
      }
    );
  });
});

