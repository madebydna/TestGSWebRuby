import { introJs } from 'intro.js';

const t = function(string) {
    if (window.GS && GS.I18n && GS.I18n.t) {
        return GS.I18n.t(string) || string;
    } else {
        return string;
    }
}

let firstTutorialLastStep = {
    element: '.school-name-container',
    highlightClass: 'no-highlight',
    intro: GS.I18n.t('tour1.step9_html')
};

let secondTutorialLastStep = {
  element: '.school-name-container',
  highlightClass: 'no-highlight',
  intro: GS.I18n.t('tour2.step12')
};

let firstTutorial = [
  {
    element: 'div.logo',
    intro: GS.I18n.t('tour1.step1'),
    position: 'bottom',
    gaLabel: 'about'
  },
  {
    element: '.rs-gs-rating',
    intro: GS.I18n.t('tour1.step2_title_html') + GS.I18n.t('tour1.step2'),
    position: 'bottom',
    gaLabel: 'summary-rating'
  },
  {
    element: '#TestScores .module-header',
    intro: GS.I18n.t('tour1.step3_title_html') + GS.I18n.t('tour1.step3'),
    position: 'top',
    gaLabel: 'academics'
  },
  {
    element: '#EquityRaceEthnicity .title-bar',
    intro: GS.I18n.t('tour1.step4_title_html') + GS.I18n.t('tour1.step4'),
    position: 'top',
    gaLabel: 'equity'
  },
  {
    element: '#osp-school-info .module-header',
    intro: GS.I18n.t('tour1.step5_title_html') + GS.I18n.t('tour1.step5'),
    position: 'top',
    gaLabel: 'environment'
  },
  {
    element: '#Reviews',
    intro: GS.I18n.t('tour1.step6_title_html') + GS.I18n.t('tour1.step6'),
    position: 'top',
    gaLabel: 'reviews'
  },
  {
    element: '#NearbySchools .title-bar',
    intro: GS.I18n.t('tour1.step7_title_html') + GS.I18n.t('tour1.step7'),
    position: 'top',
    gaLabel: 'nearby'
  },
  {
    element: '.school-info',
    highlightClass: 'no-highlight',
    intro: GS.I18n.t('tour1.step8_title_html') + '<div class="info-circle"><span class="icon-question"></span></div>' + '<br><br>' + GS.I18n.t('tour1.step8_p1') + '<br><br>' + '<p class="parent-tip"><img src="/assets/school_profiles/owl.png"><span class="speech-bubble left">Parent tips</span></p>' + GS.I18n.t('tour1.step8_p2') + '<br><br>' + '<div style="font-size: 18px; color: blue;">Sources</div>' + '<br>'+ GS.I18n.t('tour1.step8_p3')
  }
];

let secondTutorial = [
  {
      element: '#TestScores .module-header',
      intro: GS.I18n.t('tour2.step1_title_html') + GS.I18n.t('tour2.step1'),
      position: 'top'
  },
  {
      element: '#CollegeReadiness .module-header',
      intro: GS.I18n.t('tour2.step2_title_html') + GS.I18n.t('tour2.step2'),
      position: 'top'
  },
  {
      element: '#StudentProgress .module-header',
      intro: GS.I18n.t('tour2.step3_title_html') + GS.I18n.t('tour2.step3'),
      position: 'top'
  },
  {
      element: '#AdvancedCourses .module-header',
      intro: GS.I18n.t('tour2.step4_title_html') + GS.I18n.t('tour2.step4'),
      position: 'top'
  },
  {
      element: '#AdvancedCourses .module-header',
      intro: GS.I18n.t('tour2.step5_title_html') + GS.I18n.t('tour2.step5'),
      position: 'top'
  },
  {
      element: '#EquityRaceEthnicity .title-bar',
      intro: GS.I18n.t('tour2.step6_title_html') + GS.I18n.t('tour2.step6'),
      position: 'top'
  },
  {
      element: '#EquityLowIncome .title-bar',
      intro: GS.I18n.t('tour2.step7_title_html') + GS.I18n.t('tour2.step7'),
      position: 'top'
  },
  {
      element: '#EquityDisabilities .title-bar',
      intro: GS.I18n.t('tour2.step8_title_html') + GS.I18n.t('tour2.step8'),
      position: 'top'
  },
  {
      element: '#osp-school-info .module-header',
      intro: GS.I18n.t('tour2.step9_title_html') + GS.I18n.t('tour2.step9'),
      position: 'top'
  },
  {
      element: '#Students .module-header',
      intro: GS.I18n.t('tour2.step10_title_html') + GS.I18n.t('tour2.step10'),
      position: 'top'
  },
  {
      element: '#TeachersStaff .module-header',
      intro: GS.I18n.t('tour2.step11_title_html') + GS.I18n.t('tour2.step11'),
      position: 'top'
  }
]


let numberOfVisibleSteps;

let intro;

const homesAndRentalsSelector = '#homes-and-rentals';

const onStepSeen = function(targetElement) {
  let stepNum = intro._currentStep;
  let gaLabel = firstTutorial[stepNum].gaLabel;
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
    if (numberOfVisibleSteps == intro._currentStep + 1) {
        $('.introjs-bullets, .introjs-tooltipbuttons').hide();
        $('.introjs-tooltip').css({'text-align':'center', 'padding': '20px'});
    }
};

const getFilteredSteps = function(tutorial) {
    return tutorial.filter(function(obj) {
        return $(obj.element).length;
    });
}

export function exit() {
    introJs().exit();
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
    onafterchange(onStepSeen).
    onexit(onExitTour).
    onbeforechange(handleLastStep);
    $(homesAndRentalsSelector).hide();
    intro.start();
}

export function startFirstTutorial() {
  startTutorial(firstTutorial, firstTutorialLastStep);
}

// Ensure that first tutorial is exited before new tutorial fires
function exitLastTour(){
    return new Promise(function(resolve, reject) {
        intro.exit();
        resolve();
    });
};

export function startSecondTutorial(){
    exitLastTour().then( function() {
        startTutorial(secondTutorial, secondTutorialLastStep);
    })
}
