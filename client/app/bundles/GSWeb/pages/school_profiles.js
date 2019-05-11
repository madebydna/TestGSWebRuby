// TODO: import ad addCompfilterToGlobalAdTargetingGon

import { getStore } from '../store/appStore';

import 'js-cookie';
import '../vendor/fastclick';
import DataModule from '../react_components/data_module';
import StudentsWithDisabilities from '../react_components/equity/students_with_disabilities';
import CollegeReadiness from '../react_components/college_readiness';
import ReviewDistribution from '../react_components/review_distribution';
import Reviews from '../react_components/review/reviews';
import NearestHighPerformingSchools from '../react_components/nearest_high_performing_schools';
import Courses from '../react_components/courses';
import { makeDrawersWithSelector } from '../components/drawer';
import { generateEthnicityChart } from '../components/ethnicity_pie_chart';
import { fixToTopWhenBelowY } from '../util/fix_to_top_when_below_y';
import { generateSubgroupPieCharts } from '../components/subgroup_charts';
import * as stickyRightRail from '../components/sticky_right_rail';
import * as schoolProfileStickyCTA from '../components/school_profile_sticky_cta';
import * as schoolProfileStickyCTAMobile from '../components/school_profile_sticky_cta_mobile';
import { viewport } from '../util/viewport';
import OspSchoolInfo from '../react_components/osp_school_info';
import TopicalReviewSummary from '../react_components/topical_review_summary';
import Toggle from '../components/toggle';
import HomesAndRentals from '../react_components/homes_and_rentals';
import StemCourses from '../react_components/school_profiles/stem_courses';
import { signupAndFollowSchool, updateProfileHeart } from '../util/newsletters';
import * as backToTop from '../components/back_to_top';
import { impressionTracker } from '../util/impression_tracker';
import { t } from '../util/i18n';
import refreshAdOnScroll from '../util/refresh_ad_on_scroll';
import * as introJs from '../components/introJs';
import { scrollToElement } from '../util/scrolling';
import { enableAutoAnchoring, initAnchorHashUpdater, scrollToAnchor } from '../components/anchor_router';
import { assign } from 'lodash';
import * as validatingInputs from 'components/validating_inputs';
import owlPng from 'school_profiles/owl.png';
import { minimizeNudges as minimizeQualarooNudges } from 'util/qualaroo';
import { init as initAdvertising, enableAdCloseButtons } from 'util/advertising';
import {
  registerInterrupt,
  registerPredefinedInterrupts,
  runInterrupts
} from 'util/interrupts';
import SearchBox from 'react_components/search_box';
import withViewportSize from 'react_components/with_viewport_size';
import ProfileInterstitialAd, { shouldShowInterstitial, profileInterstitialLoader } from 'react_components/school_profiles/profile_interstitial_ad';
import "jquery-unveil";
import commonPageInit from '../common';
import { throttle, debounce } from 'lodash';
import { boxInDoc, relativeToViewport, relativeToViewportTop, firstInViewport, keepInViewport } from 'util/viewport';

const SearchBoxWrapper = withViewportSize({ propName: 'size' })(SearchBox);

window.store = getStore();

ReactOnRails.register({
  DataModule,
  StudentsWithDisabilities,
  CollegeReadiness,
  ReviewDistribution,
  Reviews,
  NearestHighPerformingSchools,
  Courses,
  OspSchoolInfo,
  HomesAndRentals,
  StemCourses,
  TopicalReviewSummary,
  SearchBoxWrapper,
  ProfileInterstitialAd
});

$(function() {
  commonPageInit();

  (function() {
    var toggle = assign(new Toggle($('#hero').find('.school-contact')));
    toggle.effect = "slideToggle";
    toggle.addCallback(
        toggle.updateButtonTextCallback(t('show_less'), t('see_more_contact'))
    );
    toggle.init().add_onclick();
  })();

  // has to go above tooltips.initialize();
  $('.tour-teaser').addClass('gs-tipso');
  $('.tour-teaser').attr('data-remodal-target', 'modal_info_box')

  registerInterrupt('interstitial', (nextInterrupt) => {
    if(shouldShowInterstitial()) {
      profileInterstitialLoader.load();
    } else {
      nextInterrupt();
    }
  });

  initAnchorHashUpdater();

  enableAutoAnchoring({
    'Test_scores': '#TestScores .profile-module',
    'College_readiness': '#CollegeReadiness .profile-module',
    'College_success': '#CollegeSuccess .profile-module',
    'Advanced_courses': '#AdvancedCourses .profile-module',
    'Low-income_students': '#EquityLowIncome .profile-module',
    'Race_ethnicity': '#EquityRaceEthnicity .profile-module',
    'Students_with_Disabilities': '#EquityDisabilities .profile-module',
    'Students': '#Students',
    'Teachers_staff': '#TeachersStaff',
    'Reviews': '#Reviews',
    'Neighborhood': '#Neighborhood',
    'Academic_progress': '#AcademicProgress',
    'Equity_overview': '#EquityOverview'
  });
  generateEthnicityChart(gon.ethnicity);
  makeDrawersWithSelector($('.js-drawer'));
  generateSubgroupPieCharts();
  stickyRightRail.init();
  schoolProfileStickyCTA.init();
  schoolProfileStickyCTAMobile.init();
  backToTop.init();

  $('.js-followThisSchool').on('click', function () {
    signupAndFollowSchool(gon.school.state, gon.school.id);
  });

  $('body').on('click', '.js-sharingLinks', function () {
    var url = $(this).data("link") + encodeURIComponent($(this).data("url"));
    if($(this).data("siteparams") !== undefined) {
      url +=  $(this).data("siteparams");
    }
    popupCenter(url, $(this).data("type"), 700, 300)
    return false;
  });

  $('body').on('click', '.js-slTracking', function () {
    var cat = $(this).data("module") +"::"+ $(this).data("type");
    analyticsEvent('Profile', 'Share', cat);
    return false;
  });

  $('body').on('click', '.js-subtopicAnswerButton', function () {
    analyticsEvent('Profile', 'Answer', '11');
  });

  function popupCenter(url, title, w, h) {
    // Fixes dual-screen position                         Most browsers      Firefox
    var dualScreenLeft = window.screenLeft != undefined ? window.screenLeft : screen.left;
    var dualScreenTop = window.screenTop != undefined ? window.screenTop : screen.top;

    var width = window.innerWidth ? window.innerWidth : document.documentElement.clientWidth ? document.documentElement.clientWidth : screen.width;
    var height = window.innerHeight ? window.innerHeight : document.documentElement.clientHeight ? document.documentElement.clientHeight : screen.height;

    var left = ((width / 2) - (w / 2)) + dualScreenLeft;
    var top = ((height / 2) - (h / 2)) + dualScreenTop;
    var newWindow = window.open(url, title, 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,width=' + w + ',height=' + h + ',top=' + top + ',left=' + left);

    // Puts focus on the newWindow
    if (window.focus) {
      newWindow.focus();
    }
  }

  function touchDevice(){
    return (('ontouchstart' in window)
    || (navigator.maxTouchPoints > 0)
    || (navigator.msMaxTouchPoints > 0));
  }

  $('body').on('click', '.js-permaLink', function () {
    if(!touchDevice()) {
      $(this).focus();
      $(this).select();
      document.execCommand("copy");
      $(this).siblings().css('display', 'block');
    }
    return false;
  });

  $('body').on('click', '.js-emailSharingLinks', function () {
    window.location.href = ($(this).data("link"));
    return false;
  });

  $('.profile-section .section-title').each(function() {
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

  keepInViewport('.left-rail-jumpy-ad', {
    elementsAboveFunc: () => {
      // get list of titles in reverse order. reverse() mutates the array
      let titles = [].slice.call(window.document.querySelectorAll('.section-title'));
      let titlesReversed = [].slice.call(window.document.querySelectorAll('.section-title')).reverse();
      // we want the ad below the section title that's farthest down the document, but
      // one that's within 480px of the top of the viewport
      let titleToPutAdBelow = titlesReversed.find(el => relativeToViewport(el).top < 480);
      titleToPutAdBelow = titleToPutAdBelow || firstInViewport(titles);
      return titleToPutAdBelow || [];
    },
    elementsBelowFunc: () => [].slice.call(window.document.querySelectorAll('.js-Profiles_Third_Ad-wrapper')),
    setTop: true,
    setBottom: true,
    hideIfNoSpace: true
  });



  $('body').on('click', '.js-moreRevealLink', function () {
    $(this).hide();
    $(this).siblings('.js-moreReveal').removeClass('more-reveal');
  });

  refreshAdOnScroll('Profiles_First_Ad', '.static-container', 1200);
  refreshAdOnScroll('Profiles_SecondSticky_Ad', '.static-container', 1200);

  function setCookieExpiration() {
    var half_year = 182*24*60*60*1000
    var date = new Date();
    date.setTime(date.getTime() + half_year);
    var expires = "; expires=" + date.toUTCString();
    return expires;
  }

  function setCookie(name, value) {
    document.cookie = name + '=' + value + setCookieExpiration() + "; path=/";
  }

  // The tour modal will appear by default unless the user clicks 'Not right now'
  // When clicked we update the cookie to reflect the user's preference and make
  // sure the modal isn't displayed again.
  $('body').on('click', '#close-school-tour', function() {
    $('.school-profile-tour-modal').remove();
    $('.tour-teaser').tipso({content: '<div><div><h3><img src="' + owlPng + '"/> Welcome!</h3>You&apos;re seeing our new, improved GreatSchools School Profile.</div><br/><button class="tour-cta js-start-tour active">Start tour</button></div>', width: 300, tooltipHover: true});
    $('.tour-teaser').attr('data-remodal-target', 'modal_info_box')
  });

  let $body = $('body');

  // used by test scores in school profiles
  $body.on('click', '.js-test-score-details', function () {
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

  // closes drawers when a new subject is selected for test scores in school profiles
  $body.on('click','.js-updateLocationHash',function(){
    const gradesContainer = $(this).parent().parent().parent();
    const grades = gradesContainer.find('.grades');
    grades.slideUp();

    const caretSpans = gradesContainer.find('span.icon-caret-down')
    caretSpans.each((idx)=>{
      if(!caretSpans[idx].classList.contains('rotate-text-270')){
        caretSpans[idx].classList.add('rotate-text-270');
      }
    })
  });

  // for summary rating tooltip
  $body.on('click', '.js-rating-details', function () {
    var ratingDescription = $(this).closest('.rating-table-row').find('.rating-table-description');
    if(ratingDescription.css('display') == 'none') {
      ratingDescription.slideDown();
      $(this).find('span').removeClass('rotate-text-270');
    }
    else{
      ratingDescription.slideUp();
      $(this).find('span').addClass('rotate-text-270');
    }
  });


  // for historical ratings
  $body.on('click', '.js-historical-button', function () {
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

  GS.ad.addCompfilterToGlobalAdTargetingGon();

  try {
    $('.neighborhood-module img[data-src]').unveil(300, function() {
      $(this).width('100%')
    });
  } catch (e) {}
  try {
    $('.innovate-logo').unveil(300);
  } catch (e) {}

  $body.on('click', '.js-start-tour', function() {
    let remodal = $('.js-start-tour').closest('.remodal');
    // This is the modal that appears unless the user clicks 'Not right now'
    let schoolTourModal = $('.js-school-profile-tour-modal');
    if(remodal.length > 0) {
      remodal.remodal().close();
    }
    if(schoolTourModal.length) {
      schoolTourModal.remove();
    }
    scrollToElement('body');
    introJs.startFirstTutorial();
    // Don't show the tour modal if the user takes the tour
    return false;
  }).show();

  $body.on('click', '#school-tour-feedback', function(){
    let surveyUrl = 'https://s.qualaroo.com/45194/9da69ac2-e50b-4c8d-84c1-9df4e8671481?state=' + gon.school.state + '&school=' + gon.school.id;
    window.open(surveyUrl);
  });

  $body.on('click', '.js-swd-modal', function(){
    scrollToElement('#Reviews');
    $('.remodal').remodal().close();
  });

  $body.on('click', '.js-start-second-tour', function(){
      introJs.startSecondTutorial();
      return false;
  }).show();

  $body.on('click', '.js-close-school-tour', function() {
    introJs.exit();
  });

  validatingInputs.addFilteringEventListener('body');

});

$(window).on('load', function() {
  initAdvertising();

  var moduleIds = [
    '#TestScores',
    '#CollegeReadiness',
    '#CollegeSuccess',
    '#StudentProgress',
    '#AdvancedCourses',
    '#EquityOverview',
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

  registerPredefinedInterrupts(['mobileOverlayAd', 'qualaroo'])
  runInterrupts(['interstitial', 'profileTour', 'mobileOverlayAd', 'qualaroo'])

  $('#toc').on('click', 'a', function(e) {
    const ANCHOR_REGEX = /^#[^ ]+$/;
    let elem = e.currentTarget;
    if(elem.nodeName === 'A') {
      let href = elem.getAttribute('href');
      if(href != window.location.hash) {
        window.location.hash = href;
      } else {
        scrollToAnchor(href.slice(1));
      }
    }
  });
});

document.addEventListener('DOMContentLoaded', () => {updateProfileHeart(gon.school.state, gon.school.id)});