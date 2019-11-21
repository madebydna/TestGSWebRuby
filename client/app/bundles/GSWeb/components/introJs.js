import { introJs } from 'intro.js';
import { t } from '../util/i18n';
import { withCurrentSchool } from 'store/appStore';
import owlPng from 'school_profiles/owl.png';
import {
  minimizeNudges as minimizeQualarooNudges,
  maximizeNudges as maximizeQualarooNudges
} from 'util/qualaroo';

let numberOfVisibleSteps;

let intro;

const homesAndRentalsSelector = '#homes-and-rentals';

const firstTutorialLastStep = {
  element: '.school-name-container',
  highlightClass: 'no-highlight',
  intro: t('school_profile_tour.tour1.step9_html'),
  gaLabel: 'end-tutorial-A'
};

const secondTutorialLastStep = {
  element: '.school-name-container',
  highlightClass: 'no-highlight',
  intro: t('school_profile_tour.tour2.step12'),
  gaLabel: 'end-tutorial-B'
};

const firstTutorial = [
  {
    element: '.rs-gs-rating',
    intro: t('school_profile_tour.tour1.step2_title_html') + t('school_profile_tour.tour1.step2'),
    position: 'below',
    gaLabel: 'summary-rating',
    tooltipClass: 'gs-rating-tour-item'
  },
  {
    element: '#academics-tour-anchor',
    intro: t('school_profile_tour.tour1.step3_title_html') + t('school_profile_tour.tour1.step3'),
    position: 'top',
    gaLabel: 'academics'
  },
  {
    element: '#equity-tour-anchor',
    intro: t('school_profile_tour.tour1.step4_title_html') + t('school_profile_tour.tour1.step4'),
    position: 'top',
    gaLabel: 'equity'
  },
  {
    element: '#environment-tour-anchor',
    intro: t('school_profile_tour.tour1.step5_title_html') + t('school_profile_tour.tour1.step5'),
    position: 'top',
    gaLabel: 'environment'
  },
  {
    element: '#Reviews',
    intro: t('school_profile_tour.tour1.step6_title_html') + t('school_profile_tour.tour1.step6'),
    highlightClass: 'no-highlight',
    position: 'top',
    gaLabel: 'reviews'
  },
  {
    element: '#NearbySchools .button-bar',
    intro: t('school_profile_tour.tour1.step7_title_html') + t('school_profile_tour.tour1.step7'),
    highlightClass: 'no-highlight',
    position: 'top',
    gaLabel: 'nearby'
  },
  {
    element: '#NearbySchools .button-bar',
    highlightClass: 'no-highlight',
    intro:
      `${t(
        'school_profile_tour.tour1.step8_title_html'
      )}<div class="info-circle"><span class="icon-question"></span></div>` +
      `<br><br>${t('school_profile_tour.tour1.step8_p1')}<br><br>` +
      `<p class="parent-tip"><img src="${owlPng}"><span class="speech-bubble left">${t(
        'school_profile_tour.tour1.step8_parent_tips'
      )}</span></p>${t('school_profile_tour.tour1.step8_p2')}<br><br>` +
      `<div style="font-size: 18px; color: blue;">${t(
        'school_profile_tour.tour1.step8_sources'
      )}</div>` +
      `<br>${t('school_profile_tour.tour1.step8_p3')}`,
    gaLabel: 'hints',
    position: 'top'
  }
];

const firstTutorialForTestScoresOnlyRating = [
  {
    element: '.rs-gs-rating',
    intro:
      t('school_profile_tour.tour1.step2_test_scores_only_title_html') +
      t('school_profile_tour.tour1.step2_test_scores_only'),
    position: 'below',
    gaLabel: 'summary-rating'
  }
].concat(firstTutorial.slice(1));

const secondTutorial = [
  {
    element: '#CollegeReadiness .module-header',
    intro: t('school_profile_tour.tour2.step1_title_html') + t('school_profile_tour.tour2.step1'),
    position: 'top',
    gaLabel: 'college-readiness'
  },
  {
    element: '#TestScores .module-header',
    intro: t('school_profile_tour.tour2.step2_title_html') + t('school_profile_tour.tour2.step2'),
    position: 'top',
    gaLabel: 'test-scores'
  },
  {
    element: '#StudentProgress .module-header',
    intro: t('school_profile_tour.tour2.step3_title_html') + t('school_profile_tour.tour2.step3'),
    position: 'top',
    gaLabel: 'progress'
  },
  {
    element: '#AdvancedCourses .module-header',
    intro: t('school_profile_tour.tour2.step4_title_html') + t('school_profile_tour.tour2.step4'),
    position: 'top',
    gaLabel: 'adv-courses'
  },
  {
    element: '.stem-module .module-header',
    intro: t('school_profile_tour.tour2.step5_title_html') + t('school_profile_tour.tour2.step5'),
    position: 'top',
    gaLabel: 'stem-courses'
  },
  {
    element: '#EquityRaceEthnicity .module-header',
    intro: t('school_profile_tour.tour2.step6_title_html') + t('school_profile_tour.tour2.step6'),
    position: 'top',
    gaLabel: 'race'
  },
  {
    element: '#EquityLowIncome .module-header',
    intro: t('school_profile_tour.tour2.step7_title_html') + t('school_profile_tour.tour2.step7'),
    position: 'top',
    gaLabel: 'low-income'
  },
  {
    element: '#EquityDisabilities .module-header',
    intro: t('school_profile_tour.tour2.step8_title_html') + t('school_profile_tour.tour2.step8'),
    position: 'top',
    gaLabel: 'disabilities'
  },
  {
    element: '#osp-school-info .module-header',
    intro: t('school_profile_tour.tour2.step9_title_html') + t('school_profile_tour.tour2.step9'),
    position: 'top',
    gaLabel: 'general'
  },
  {
    element: '#Students .module-header',
    intro: t('school_profile_tour.tour2.step10_title_html') + t('school_profile_tour.tour2.step10'),
    position: 'top',
    gaLabel: 'students'
  },
  {
    element: '#TeachersStaff .module-header',
    intro: t('school_profile_tour.tour2.step11_title_html') + t('school_profile_tour.tour2.step11'),
    position: 'top',
    gaLabel: 'teachers'
  }
];

const onStepSeen = function(targetElement, tutorial) {
  const stepNum = intro._currentStep;
  const gaLabel = tutorial[stepNum].gaLabel;
  window.analyticsEvent(
    'Profile',
    'tutorial-public',
    gaLabel || stepNum + 1,
    true
  );
};

const onExitTour = function() {
  maximizeQualarooNudges();
  $(homesAndRentalsSelector).show();
  const stepNum = intro._currentStep + 1;
  if (stepNum < numberOfVisibleSteps) {
    window.analyticsEvent(
      'Profile',
      'tutorial-public',
      `cancel-step ${stepNum}`
    );
  }
  $('.tour-teaser').attr('data-remodal-target', 'modal_info_box');
};

const handleLastStep = function() {
  if (numberOfVisibleSteps === intro._currentStep + 1) {
    $('.introjs-bullets, .introjs-tooltipbuttons').hide();
    $('.introjs-tooltip').css({ 'text-align': 'center', padding: '20px' });
  } else {
    $('.introjs-bullets, .introjs-tooltipbuttons').show();
  }
};

const getFilteredSteps = function(tutorial) {
  return tutorial.filter(obj => obj.element === null || $(obj.element).length);
};

export function exit() {
  maximizeQualarooNudges();
  intro.exit();
}

const startTutorial = function(tutorial, lastStep) {
  // use jQuery to filter out elements that dont exist
  const filteredSteps = getFilteredSteps(tutorial);
  const allSteps = filteredSteps.concat([lastStep]);
  numberOfVisibleSteps = allSteps.length;
  intro = introJs()
    .setOptions({
      showStepNumbers: false,
      steps: allSteps,
      hidePrev: true,
      hideNext: true,
      showProgress: false,
      skipLabel: 'cancel',
      overlayOpacity: 0,
      exitOnOverlayClick: true,
      scrollPadding: 80
    })
    .onafterchange(targetElement => {
      onStepSeen(targetElement, allSteps);
    })
    .onexit(onExitTour)
    .onbeforechange(handleLastStep);
  $(homesAndRentalsSelector).hide();
  minimizeQualarooNudges();
  intro.start();
};

// Ensure that first tutorial is exited before new tutorial fires
function exitLastTour() {
  return new Promise((resolve, reject) => {
    intro.exit();
    resolve();
  });
}

export function startFirstTutorial() {
  withCurrentSchool((state, id, { test_scores_only = false } = {}) => {
    if (test_scores_only) {
      startTutorial(
        firstTutorialForTestScoresOnlyRating,
        firstTutorialLastStep
      );
    } else {
      startTutorial(firstTutorial, firstTutorialLastStep);
    }
  });
}

export function startSecondTutorial() {
  exitLastTour().then(() => {
    startTutorial(secondTutorial, secondTutorialLastStep);
  });
}
