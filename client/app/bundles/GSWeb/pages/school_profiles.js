// TODO: import ad addCompfilterToGlobalAdTargetingGon
/* global gon, $, ReactOnRails, GS, analyticsEvent */
import 'js-cookie';
import { assign } from 'lodash';
import owlSvg from 'school_profiles/brown-owl.svg';
import { init as initAdvertising, applyStylingToIFrameAd } from 'util/advertising';
import {
  registerInterrupt,
  registerPredefinedInterrupts,
  runInterrupts
} from 'util/interrupts';
import SearchBox from 'react_components/search_box';
import withViewportSize from 'react_components/with_viewport_size';
import { viewport, relativeToViewport, firstInViewport, keepInViewport, isScrolledInViewport } from 'util/viewport';
import { init as initAnimation } from 'util/animation';
import ProfileInterstitialAd, { shouldShowInterstitial, profileInterstitialLoader } from 'react_components/school_profiles/profile_interstitial_ad';
import "jquery-unveil";
import * as validatingInputs from '../components/validating_inputs';
import commonPageInit from '../common';
import { getStore } from '../store/appStore';
import '../vendor/fastclick';
import DataModule from '../react_components/data_module';
import LowIncomeDataModule from '../react_components/school_profiles/low_income_data_module';
import StudentsWithDisabilities from '../react_components/equity/students_with_disabilities';
import CollegeReadiness from '../react_components/college_readiness';
import ReviewDistribution from '../react_components/review_distribution';
import Reviews from '../react_components/review/reviews';
import NearestHighPerformingSchools from '../react_components/nearest_high_performing_schools';
import { makeDrawersWithSelector } from '../components/drawer';
import { generateEthnicityChart } from '../components/ethnicity_pie_chart';
import { fixToTopWhenBelowY } from '../util/fix_to_top_when_below_y';
import { generateSubgroupPieCharts } from '../components/subgroup_charts';
import * as stickyRightRail from '../components/sticky_right_rail';
import * as schoolProfileStickyCTA from '../components/school_profile_sticky_cta';
import * as schoolProfileStickyCTAMobile from '../components/school_profile_sticky_cta_mobile';
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

const SearchBoxWrapper = withViewportSize({ propName: 'size' })(SearchBox);

window.store = getStore();

ReactOnRails.register({
  DataModule,
  LowIncomeDataModule,
  StudentsWithDisabilities,
  CollegeReadiness,
  ReviewDistribution,
  Reviews,
  NearestHighPerformingSchools,
  OspSchoolInfo,
  HomesAndRentals,
  StemCourses,
  TopicalReviewSummary,
  SearchBoxWrapper,
  ProfileInterstitialAd
});

$(() => {
  commonPageInit();

  (() => {
    const toggle = assign(new Toggle($('#hero').find('.school-contact')));
    toggle.effect = "slideToggle";
    toggle.addCallback(
        toggle.updateButtonTextCallback(t('show_less'), t('see_more_contact'))
    );
    toggle.init().add_onclick();
  })();

  // has to go above tooltips.initialize();
  $('.tour-teaser').addClass('gs-tipso');
  $('.tour-teaser').attr('data-remodal-target', 'modal_info_box');

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

  function popupCenter(url, title, w, h) {
    // Fixes dual-screen position                         Most browsers      Firefox
    const dualScreenLeft = window.screenLeft !== undefined ? window.screenLeft : screen.left;
    const dualScreenTop = window.screenTop !== undefined ? window.screenTop : screen.top;

    let width;
    let height;

    if (window.innerWidth) {
      width = window.innerWidth;
    } else if (document.documentElement.clientWidth) {
      width = document.documentElement.clientWidth;
    } else {
      width = screen.width;
    }

    if (window.innerHeight) {
      height = window.innerHeight;
    } else if (document.documentElement.clientHeight) {
      height = document.documentElement.clientHeight;
    } else {
      height = screen.height;
    }

    const left = ((width / 2) - (w / 2)) + dualScreenLeft;
    const top = ((height / 2) - (h / 2)) + dualScreenTop;
    const newWindow = window.open(url, title, `menubar=no,toolbar=no,resizable=yes,scrollbars=yes,width=${w},height=${h},top=${top},left=${left}`);

    // Puts focus on the newWindow
    if (window.focus) {
      newWindow.focus();
    }
  }

  $('.js-followThisSchool').on('click', function() {
    signupAndFollowSchool(gon.school.state, gon.school.id);
  });

  $('body').on('click', '.js-sharingLinks', function()  {
    let url = $(this).data("link") + encodeURIComponent($(this).data("url"));
    if($(this).data("siteparams") !== undefined) {
      url +=  $(this).data("siteparams");
    }
    popupCenter(url, $(this).data("type"), 700, 300);
    return false;
  });

  $('body').on('click', '.js-slTracking', function() {
    const cat = `${$(this).data("module")}::${$(this).data("type")}`;
    analyticsEvent('Profile', 'Share', cat);
    return false;
  });

  $('body').on('click', '.js-subtopicAnswerButton', function() {
    analyticsEvent('Profile', 'Answer', '11');
  });

  function touchDevice(){
    return (('ontouchstart' in window) ||
    (navigator.maxTouchPoints > 0) ||
    (navigator.msMaxTouchPoints > 0));
  }

  $('body').on('click', '.js-permaLink', function() {
    if(!touchDevice()) {
      $(this).focus();
      $(this).select();
      document.execCommand("copy");
      $(this).siblings().css('display', 'block');
    }
    return false;
  });

  $('body').on('click', '.js-emailSharingLinks', function() {
    window.location.href = ($(this).data("link"));
    return false;
  });

  $('.profile-section .section-title').each(function(){
    const minWidth = 1200;
    const $elem = $(this);
    fixToTopWhenBelowY(
      $elem,
      (el) => el.parent().offset().top - 20,
      (el) => el.parent().offset().top + el.parent().parent().parent().height() - 50 - el.height(),
      () => viewport().width >= minWidth
    );
  });

  keepInViewport('.left-rail-jumpy-ad', {
    elementsAboveFunc: () => {
      // get list of titles in reverse order. reverse() mutates the array
      const titles = [].slice.call(window.document.querySelectorAll('.section-title'));
      const titlesReversed = [].slice.call(window.document.querySelectorAll('.section-title')).reverse();
      // we want the ad below the section title that's farthest down the document, but
      // one that's within 480px of the top of the viewport
      let titleToPutAdBelow = titlesReversed.find(el => relativeToViewport(el).top < 480);
      titleToPutAdBelow = titleToPutAdBelow || firstInViewport(titles);
      return titleToPutAdBelow || [];
    },
    elementsBelowFunc: () => [].slice.call(window.document.querySelectorAll('.js-greatschools_Profiles_Third_1-wrapper')),
    setTop: true,
    setBottom: true,
    hideIfNoSpace: true
  });

  $('body').on('click', '.js-moreRevealLink', function() {
    $(this).hide();
    $(this).siblings('.js-moreReveal').removeClass('more-reveal');
  });

  refreshAdOnScroll('greatschools_Profiles_First', '.static-container', 1200);
  refreshAdOnScroll('greatschools_Profiles_SecondSticky', '.static-container', 1200);

  // The tour modal will appear by default unless the user clicks 'Not right now'
  // When clicked we update the cookie to reflect the user's preference and make
  // sure the modal isn't displayed again.
  $('body').on('click', '#close-school-tour', function() {
    $('.school-profile-tour-modal').remove();
    $('.tour-teaser').tipso({content: `<div><div><h3><img alt="" src=${owlSvg}/> Welcome!</h3>You&apos;re seeing our new, improved GreatSchools School Profile.</div><br/><button class="tour-cta js-start-tour active">Start tour</button></div>`, width: 300, tooltipHover: true});
    $('.tour-teaser').attr('data-remodal-target', 'modal_info_box');
  });

  const $body = $('body');

  // used by test scores in school profiles
  $body.on('click', '.js-test-score-details', function() {
    const grades = $(this).closest('.bar-graph-display').parent().find('.grades');
    if(grades.css('display') === 'none') {
      grades.slideDown();
      $(this).find('span').removeClass('rotate-text-270');
    }
    else{
      grades.slideUp();
      $(this).find('span').addClass('rotate-text-270');
    }
  });

  // closes drawers when a new subject is selected for test scores in school profiles
  $body.on('click','.js-updateLocationHash', function() {
    const gradesContainer = $(this).parents('.panel');
    const grades = gradesContainer.find('.grades');
    grades.slideUp();

    const caretSpans = gradesContainer.find('span.icon-caret-down');
    caretSpans.each((idx)=>{
      if(!caretSpans[idx].classList.contains('rotate-text-270')){
        caretSpans[idx].classList.add('rotate-text-270');
      }
    });
  });

  // for summary rating tooltip
  $body.on('click', '.js-rating-details', function() {
    const ratingDescription = $(this).closest('.rating-table-row').find('.rating-table-description');
    if(ratingDescription.css('display') === 'none') {
      ratingDescription.slideDown();
      $(this).find('span').removeClass('rotate-text-270');
    }
    else{
      ratingDescription.slideUp();
      $(this).find('span').addClass('rotate-text-270');
    }
  });


  // for historical ratings
  $body.on('click', '.js-historical-button', function() {
    const historicalData = $(this).closest('.js-historical-module').find('.js-historical-target');
    if(historicalData.css('display') === 'none') {
      historicalData.slideDown();
      $(this).find('div').html(t('Hide past ratings'));
      analyticsEvent('Profile', 'Historical Ratings', null, null, true);
    }
    else{
      historicalData.slideUp();
      $(this).find('div').html(t('Past ratings'));
    }
  });

  GS.ad.addCompfilterToGlobalAdTargetingGon();

  try {
    $('.neighborhood-module img[data-src]').unveil(300, function() {
      $(this).width('100%');
    });
  } catch (e) {
    // Do nothing
  }
  try {
    $('.innovate-logo').unveil(300);
  } catch (e) {
    // Do nothing
  }

  $body.on('click', '.js-start-tour', function() {
    const remodal = $('.js-start-tour').closest('.remodal');
    // This is the modal that appears unless the user clicks 'Not right now'
    const schoolTourModal = $('.js-school-profile-tour-modal');
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

  $body.on('click', '#school-tour-feedback', function() {
    const surveyUrl = `https://s.qualaroo.com/45194/9da69ac2-e50b-4c8d-84c1-9df4e8671481?state=${gon.school.state}&school=${gon.school.id}`;
    window.open(surveyUrl);
  });

  $body.on('click', '.js-swd-modal', function() {
    scrollToElement('#Reviews');
    $('.remodal').remodal().close();
  });

  $body.on('click', '.js-start-second-tour', function() {
      introJs.startSecondTutorial();
      return false;
  }).show();

  $body.on('click', '.js-close-school-tour', function() {
    introJs.exit();
  });

  validatingInputs.addFilteringEventListener('body');

});

$(window).on('load', () => {
  initAdvertising();

  const moduleIds = [
    '#CollegeReadiness',
    '#TestScores',
    '#StemCourses',
    '#CollegeSuccess',
    '#StudentProgress',
    '#AcademicProgress',
    '#EquityOverview',
    '#Equity',
    '#EquityRaceEthnicity',
    '#EquityLowIncome',
    '#EquityDisabilities',
    '#osp-school-info',
    '#Students',
    '#TeachersStaff',
    '#Reviews',
    '#ReviewSummary',
    '#Neighborhood',
    '#NearbySchools'
  ];
  const elementIds = [];
  for (let x=0; x < moduleIds.length; x+=1) {
    const theId = moduleIds[x];
    elementIds.push(theId);
    elementIds.push(`${theId}-empty`);
  }
  impressionTracker({
    elements: elementIds,
    threshold: 50
  });

  registerPredefinedInterrupts(['mobileOverlayAd', 'qualaroo']);
  runInterrupts(['interstitial', 'profileTour', 'mobileOverlayAd', 'qualaroo']);


  $('#toc').on('click', 'a', (e) => {
    const elem = e.currentTarget;
    if(elem.nodeName === 'A') {
      const href = elem.getAttribute('href');
      if(href !== window.location.hash) {
        window.location.hash = href;
      } else {
        scrollToAnchor(href.slice(1));
      }
    }
  });
});

document.addEventListener('DOMContentLoaded', () => updateProfileHeart(gon.school.state, gon.school.id));

// specify style targeting on second ad found in SchoolProfiles#Show
applyStylingToIFrameAd('.js-Profiles_Second_Ad-wrapper', [300,250], 'margin-left:150px');

// animations
document.addEventListener('DOMContentLoaded', ()=>{
  const labelContainer = document.querySelector('.label-container');
  const classes = ['.line', '.coming-soon-container'];

  setTimeout(() => {
    initAnimation(labelContainer, classes)
  }, 500)
})