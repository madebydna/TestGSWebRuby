import { introJs } from 'intro.js';
import { t } from '../util/i18n';

let firstTutorialLastStep = {
  element: '.school-name-container',
  highlightClass: 'no-highlight',
  intro: t('tour1.step9_html'),
  gaLabel: 'end-tutorial-A'
};

let secondTutorialLastStep = {
  element: '.school-name-container',
  highlightClass: 'no-highlight',
  intro: t('tour2.step12'),
  gaLabel: 'end-tutorial-B'
};

let firstTutorial = [
  {
    element: '.logo',
    intro: t('tour1.step1'),
    highlightClass: 'no-highlight',
    position: 'below',
    gaLabel: 'about'
  },
  {
    element: '.rs-gs-rating',
    intro: t('tour1.step2_title_html') + t('tour1.step2'),
    position: 'below',
    gaLabel: 'summary-rating'
  },
  {
    element: '#academics-tour-anchor',
    intro: t('tour1.step3_title_html') + t('tour1.step3'),
    position: 'top',
    gaLabel: 'academics'
  },
  {
    element: '#equity-tour-anchor',
    intro: t('tour1.step4_title_html') + t('tour1.step4'),
    position: 'top',
    gaLabel: 'equity'
  },
  {
    element: '#environment-tour-anchor',
    intro: t('tour1.step5_title_html') + t('tour1.step5'),
    position: 'top',
    gaLabel: 'environment'
  },
  {
    element: '#Reviews',
    intro: t('tour1.step6_title_html') + t('tour1.step6'),
    highlightClass: 'no-highlight',
    position: 'top',
    gaLabel: 'reviews'
  },
  {
    element: '#NearbySchools .button-bar',
    intro: t('tour1.step7_title_html') + t('tour1.step7'),
    highlightClass: 'no-highlight',
    position: 'top',
    gaLabel: 'nearby'
  },
  {
    element: '#TestScores .module-header',
    highlightClass: 'no-highlight',
    intro: t('tour1.step8_title_html') + '<div class="info-circle"><span class="icon-question"></span></div>' + '<br><br>' + t('tour1.step8_p1') + '<br><br>' + '<p class="parent-tip"><img src="/assets/school_profiles/owl.png"><span class="speech-bubble left">' + t('tour1.step8_parent_tips') + '</span></p>' + t('tour1.step8_p2') + '<br><br>' + '<div style="font-size: 18px; color: blue;">' + t('tour1.step8_sources') + '</div>' + '<br>'+ t('tour1.step8_p3'),
    gaLabel: 'hints'
  }
];

let secondTutorial = [
  {
    element: '#TestScores .module-header',
    intro: t('tour2.step1_title_html') + t('tour2.step1'),
    position: 'top',
    gaLabel: 'test-scores'
  },
  {
    element: '#CollegeReadiness .module-header',
    intro: t('tour2.step2_title_html') + t('tour2.step2'),
    position: 'top',
    gaLabel: 'college-readiness'
  },
  {
    element: '#StudentProgress .module-header',
    intro: t('tour2.step3_title_html') + t('tour2.step3'),
    position: 'top',
    gaLabel: 'progress'
  },
  {
    element: '#AdvancedCourses .module-header',
    intro: t('tour2.step4_title_html') + t('tour2.step4'),
    position: 'top',
    gaLabel: 'adv-courses'
  },
  {
    element: '.stem-module .module-header',
    intro: t('tour2.step5_title_html') + t('tour2.step5'),
    position: 'top',
    gaLabel: 'stem-courses'
  },
  {
    element: '#EquityRaceEthnicity .title-bar',
    intro: t('tour2.step6_title_html') + t('tour2.step6'),
    position: 'top',
    gaLabel: 'race'
  },
  {
    element: '#EquityLowIncome .title-bar',
    intro: t('tour2.step7_title_html') + t('tour2.step7'),
    position: 'top',
    gaLabel: 'low-income'
  },
  {
    element: '#EquityDisabilities .title-bar',
    intro: t('tour2.step8_title_html') + t('tour2.step8'),
    position: 'top',
    gaLabel: 'disabilities'
  },
  {
    element: '#osp-school-info .module-header',
    intro: t('tour2.step9_title_html') + t('tour2.step9'),
    position: 'top',
    gaLabel: 'general'
  },
  {
    element: '#Students .module-header',
    intro: t('tour2.step10_title_html') + t('tour2.step10'),
    position: 'top',
    gaLabel: 'students'
  },
  {
    element: '#TeachersStaff .module-header',
    intro: t('tour2.step11_title_html') + t('tour2.step11'),
    position: 'top',
    gaLabel: 'teachers'
  }
];


let numberOfVisibleSteps;

let intro;

const homesAndRentalsSelector = '#homes-and-rentals';

const onStepSeen = function(targetElement, tutorial) {
  let stepNum = intro._currentStep;
  let gaLabel = tutorial[stepNum].gaLabel;
  window.analyticsEvent('Profile', 'tutorial-public', gaLabel || (stepNum + 1), true);
}

const onExitTour = function() {
  $(homesAndRentalsSelector).show();
  let stepNum = intro._currentStep + 1;
  if(stepNum < numberOfVisibleSteps) {
    window.analyticsEvent('Profile', 'tutorial-public', 'cancel-step ' + stepNum);
  }
};

const handleLastStep = function() {
  if (numberOfVisibleSteps === intro._currentStep + 1) {
    $('.introjs-bullets, .introjs-tooltipbuttons').hide();
    $('.introjs-tooltip').css({'text-align':'center', 'padding': '20px'});
  } else {
    $('.introjs-bullets, .introjs-tooltipbuttons').show();
  }
};

const getFilteredSteps = function(tutorial) {
  return tutorial.filter(function(obj) {
      return $(obj.element).length;
  });
}

export function exit() {
  intro.exit();
}

const startTutorial = function(tutorial, lastStep) {
  // use jQuery to filter out elements that dont exist
  let filteredSteps = getFilteredSteps(tutorial);
  let allSteps = filteredSteps.concat([lastStep]);
  numberOfVisibleSteps = allSteps.length;
  intro = introJs().
  setOptions({
    showStepNumbers: false,
    steps: allSteps,
    hidePrev: true,
    hideNext: true,
    showProgress: false,
    skipLabel: 'cancel',
    overlayOpacity: 0,
    exitOnOverlayClick: true
  }).
  onafterchange(function(targetElement){
    onStepSeen(targetElement, tutorial);
  }).
  onexit(onExitTour).
  onbeforechange(handleLastStep);
  $(homesAndRentalsSelector).hide();
  intro.start();
}

// Ensure that first tutorial is exited before new tutorial fires
function exitLastTour(){
  return new Promise(function(resolve, reject) {
    intro.exit();
    resolve();
  });
};

export function startFirstTutorial() {
  startTutorial(firstTutorial, firstTutorialLastStep);
}

export function startSecondTutorial(){
  exitLastTour().then(function() {
      startTutorial(secondTutorial, secondTutorialLastStep);
  })
}
