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
    intro: '<div></div><h1>All done!</h1><div><br/>Have a few more minutes? Learn<br/>more about the school&apos;s Academics,<br/>Equity and Environment sections.</div><br/><button class="start-tour js-start-second-tour active">Continue</button><br><br/><div> <a id="close-school-tour">Not right now </a></div></div>'
};

let secondTutorialLastStep = {
  element: '.school-name-container',
  highlightClass: 'no-highlight',
  intro: '<div><img alt="" height="42" src="http://orangestripes.com/gschool/owl/owl-2-copy-4.png" style="vertical-align: sub;" width="39" />&nbsp;<h1 style="display:inline-block;">&nbsp;All done!</h1></div><div><br/><p>Thank you for taking time to walk through our new profiles.&nbsp;<br>&nbsp;</p><div>Was this useful? <a>Give us your feedback</a></div></div></div>'
};

let firstTutorial = [
  {
    element: 'div.logo',
    intro: GS.I18n.t('tour1.step1'),
    position: 'bottom'
  },
  {
    element: '.rs-gs-rating',
    intro: GS.I18n.t('tour1.step2_title_html') + GS.I18n.t('tour1.step2'),
    position: 'bottom'
  },
  {
    element: '#TestScores .module-header',
    intro: GS.I18n.t('tour1.step3_title_html') + GS.I18n.t('tour1.step3'),
    position: 'top'
  },
  {
    element: '#EquityRaceEthnicity .title-bar',
    intro: GS.I18n.t('tour1.step4_title_html') + GS.I18n.t('tour1.step4'),
    position: 'top'
  },
  {
    element: '#osp-school-info .module-header',
    intro: GS.I18n.t('tour1.step5_title_html') + GS.I18n.t('tour1.step5'),
    position: 'top'
  },
  {
    element: '#Reviews',
    intro: GS.I18n.t('tour1.step6_title_html') + GS.I18n.t('tour1.step6'),
    position: 'top'
  },
  {
    element: '#NearbySchools .title-bar',
    intro: GS.I18n.t('tour1.step7_title_html') + GS.I18n.t('tour1.step7'),
    position: 'top'
  },
  {
    element: '.school-info',
    intro: GS.I18n.t('tour1.step8_title_html') + GS.I18n.t('tour1.step8'),
    position: 'auto'
  },
    {
    element: '#CollegeReadiness .module-header',
    intro: 'How well does this school prepare its students for college? This section offers information about college entrance tests, Advanced Placement (AP) coursework, graduation rates and more.',
    position: 'top'
  },
  {
    element: '#AdvancedCourses .module-header',
    intro: 'This section looks how well this school is doing in encouraging a large number of its students to take advanced courses, both overall and within key subject areas.',
    position: 'top'
  },
  {
    element: '#StudentProgress .module-header',
    intro: 'The <strong>Student Progress Rating</strong> gives you a sense of how much academic improvement students at this school have made year-over-year (also known as “growth”) compared with other schools in the state.',
    position: 'top'
  },
  {
    element: '#EquityLowIncome .title-bar',
    intro: 'This section looks at how well this school is serving its students from low-income families, looking at information like test scores and graduation rates.',
    position: 'top'
  },
  {
    element: '#EquityDisabilities .title-bar',
    intro: 'From this section, you can learn about test scores, chronic absenteeism and suspension rates at this school for students who have physical or learning disabilities, compared to state averages.',
    position: 'top'
  },
  {
    element: '#Students .module-header',
    intro: 'The Students section offers a snapshot of the diversity of the student population at this school.',
    position: 'top'
  },
  {
    element: '#TeachersStaff .module-header',
    intro: GS.I18n.t('tour1.step7'),
    position: 'top'
  }
];

let secondTutorial = [
  {
      element: '#TestScores .module-header',
      intro: 'Here you\'ll find a snapshot of this school\'s proficiency levels in key subjects, based on test scores and compared to state averages, with "Parent tips" you can use to learn more.',
      position: 'top'
  },
  {
      element: '#CollegeReadiness .module-header',
      intro: 'How well does this school prepare its students for college? This section offers information about college entrance tests, Advanced Placement (AP) coursework, graduation rates and more.',
      position: 'top'
  },
  {
      element: '#AdvancedCourses .module-header',
      intro: 'This section looks how well this school is doing in encouraging a large number of its students to take advanced courses, both overall and within key subject areas.',
      position: 'top'
  },
  {
      element: '#StudentProgress .module-header',
      intro: 'The <strong>Student Progress Rating</strong> gives you a sense of how much academic improvement students at this school have made year-over-year (also known as “growth”) compared with other schools in the state.',
      position: 'top'
  },
  {
      element: '#EquityRaceEthnicity .title-bar',
      intro: 'This section helps you understand how well a school is serving all of its students, looking at information like test scores and suspension rates for different racial and ethnic groups at this school.',
      position: 'top'
  },
  {
      element: '#EquityLowIncome .title-bar',
      intro: 'This section looks at how well this school is serving its students from low-income families, looking at information like test scores and graduation rates.',
      position: 'top'
  },
  {
      element: '#EquityDisabilities .title-bar',
      intro: 'From this section, you can learn about test scores, chronic absenteeism and suspension rates at this school for students who have physical or learning disabilities, compared to state averages.',
      position: 'top'
  },
  {
      element: '#osp-school-info .title-bar',
      intro: 'Here you will find information like the school\'s hours, transportation options, how to enroll, clubs and more.',
      position: 'top'
  },
  {
      element: '#Students .module-header',
      intro: 'The Students section offers a snapshot of the diversity of the student population at this school.',
      position: 'top'
  },
  {
      element: '#TeachersStaff .module-header',
      intro: 'Here you can find out more about the student per teacher or counselor ratios, teacher tenure and more.',
      position: 'top'
  },
  {
      element: '#Reviews',
      intro: 'Here, parents and others in the school community share their experiences with this school. ',
      position: 'top'
  }
]


let numberOfVisibleSteps;

let intro;

const homesAndRentalsSelector = '#homes-and-rentals';

const onStepSeen = function(targetElement) {
  let stepNum = intro._currentStep + 1;
  window.analyticsEvent('Profile', 'tutorial-public', stepNum);
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
