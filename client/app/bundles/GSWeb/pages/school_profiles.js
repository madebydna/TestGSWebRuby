import configureStore from '../store/appStore';

import 'jquery';
import '../vendor/tipso';
import '../vendor/fastclick';
import '../vendor/remodal';
import '../vendor/parsley.remote';
import '../vendor/parsley.es';
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
import OspSchoolInfo from '../react_components/osp_school_info';
import Toggle from '../components/toggle';
import HomesAndRentals from '../react_components/homes_and_rentals';
import StemCourses from '../react_components/school_profiles/stem_courses';
import { enableAutoAnchoring } from '../components/anchor_router';
import * as footer from '../components/footer';
import { signupAndFollowSchool } from '../util/newsletters';
import * as backToTop from '../components/back_to_top';
import { impressionTracker } from '../util/impression_tracker';
import { t } from '../util/i18n';
import * as facebook from '../components/facebook_auth';

window.store = configureStore({
  school: gon.school
});

ReactOnRails.register({
  SchoolProfileComponent,
  ReviewDistribution,
  Reviews,
  NearestHighPerformingSchools,
  Courses,
  OspSchoolInfo,
  HomesAndRentals,
  StemCourses
});

$(function() {
  (function() {
    var toggle = _.assign(new Toggle($('#hero').find('.school-info')));
    toggle.effect = "slideToggle";
    toggle.addCallback(
        toggle.updateButtonTextCallback(t('show_less'), t('show_more'))
    );
    toggle.init().add_onclick();
  })();

  enableAutoAnchoring({
    'Test_scores': '#TestScores .rating-container__rating',
    'College_readiness': '#CollegeReadiness .rating-container__rating',
    'Advanced_courses': '#AdvancedCourses .rating-container__rating',
    'Low-income_students': '#EquityLowIncome .equity-section',
    'Race_ethnicity': '#EquityRaceEthnicity .equity-section',
    'Students_with_Disabilities': '#EquityDisabilities .equity-section',
    'Students': '#Students',
    'Teachers_staff': '#TeachersStaff',
    'Neighborhood': '#Neighborhood'
  });
  generateEthnicityChart(gon.ethnicity);
  makeDrawersWithSelector($('.js-drawer'));
  tooltips.initialize();
  remodal.init();
  generateSubgroupPieCharts();
  stickyCTA.init();
  footer.setupNewsletterLink();
  backToTop.init();

  $('.js-followThisSchool').on('click', function () {
    signupAndFollowSchool(gon.school.state, gon.school.id);
  });

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
  
  $('body').on('click', '.multi-select-button-group label', function() {
    var $label = $(this);
    var $hiddenField = $label.closest('fieldset').find('input[type=hidden]');
    var values = $hiddenField.val().split(',');
    if ($hiddenField.val() == "") {
      values = [];
    }
    var value = $label.data('value').toString();
    var index = values.indexOf(value);
    if(index == -1) {
      values.push(value);
    } else {
      values.splice(index, 1);
    }
    $hiddenField.val(values.join(','));
    $label.toggleClass('active');
  });

  // used by test scores in school profiles
  $('body').on('click', '.js-test-score-details', function () {
    var grades = $(this).closest('.bar-graph-display').parent().find('.grades');
    if(grades.css('display') == 'none') {
      grades.slideDown();
      $(this).find('span').removeClass('rotate-text-270');
    }
    else{
      grades.slideUp();
      $(this).find('span').addClass('rotate-text-270');
    }
  });

  // for historical ratings
  $('body').on('click', '.js-historical-button', function () {
    var historical_data = $(this).closest('.js-historical-module').find('.js-historical-target');
    if(historical_data.css('display') == 'none') {
      historical_data.slideDown();
      $(this).find('div').html(t('Hide past ratings'));
      analyticsEvent('Profile', 'Historical Ratings', null, null, true);
    }
    else{
      historical_data.slideUp();
      $(this).find('div').html(t('Past ratings'));
    }
  });
  
});

$(window).on('load', function() {
  var moduleIds = [
    '#TestScores',
    '#CollegeReadiness',
    '#StudentProgress',
    '#AdvancedCourses',
    '#Equity',
    '#EquityRaceEthnicity',
    '#EquityLowIncome',
    '#EquityDisabilities',
    '#Students',
    '#TeachersStaff',
    '#Reviews',
    '#ReviewSummary',
    '#Neighborhood',
    '#NearbySchools'
  ];
  var elementIds = [];
  for (var x=0; x < moduleIds.length; x ++) {
    var theId = moduleIds[x];
    elementIds.push(theId);
    elementIds.push(theId + '-empty');
  }
  impressionTracker({
    elements: elementIds,
    threshold: 50
  });
});

$.getScript('//connect.facebook.net/en_US/sdk.js', function(){
  var appId = gon.facebook_app_id;
  FB.init({
    appId: appId,
    version    : 'v2.2',
    status     : true, // check login status
    cookie     : true, // enable cookies to allow the server to access the session
    xfbml      : true  // parse XFBML
  });
  GS.facebook.init();
});
