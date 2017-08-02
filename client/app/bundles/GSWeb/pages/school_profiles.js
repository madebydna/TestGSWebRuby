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
import OspSchoolInfo from '../react_components/osp_school_info';
import Toggle from '../components/toggle';
import HomesAndRentals from '../react_components/homes_and_rentals';
import StemCourses from '../react_components/school_profiles/stem_courses';
import { enableAutoAnchoring } from '../components/anchor_router';
import * as introJs from '../components/introJs';
import { scrollToElement } from '../util/scrolling';

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
        toggle.updateButtonTextCallback(GS.I18n.t('show_less'), GS.I18n.t('show_more'))
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

  function setCookieExpiration() {
    var expires = "";
    var date = new Date();
    date.setTime(date.getTime() + (182*24*60*60*1000));
    expires = "; expires=" + date.toUTCString();
    return expires;
  }

  function setSchoolTourCookie() {
    document.cookie = "decline_school_profile_tour=true" + setCookieExpiration() + "; path=/";
  }

  // The tour modal will appear by default unless the user clicks 'Not right now'
  // When clicked we update the cookie to reflect the user's preference and make
  // sure the modal isn't displayed again.
  $('#close-school-tour').click(function(){
    $('.school-profile-tour-modal').remove();
    $('.tour-teaser').tipso({content: '<div><div><h3>Welcome!</h3>You&apos;re seeing our new, improved GreatSchools School Profile.</div><br/><button class="start-tour js-start-tour active">Start tour</button></div>', width: 300, tooltipHover: true});
    setSchoolTourCookie();
  })
  
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

  $('body').on('click', '.js-start-tour', function() {
    let remodal = $('.js-start-tour').closest('.remodal');
    // This is the modal that appears unless the user clicks 'Not right now'
    let schoolTourModal = $('.school-profile-tour-modal');
    if(remodal.length > 0) {
      remodal.remodal().close();
    }
    if(schoolTourModal.length) {
      schoolTourModal.remove();
    }
    scrollToElement('#hero');
    introJs.start();
    // Don't show the tour modal if the user takes the tour
    setSchoolTourCookie();
    return false;
  }).show();

});

