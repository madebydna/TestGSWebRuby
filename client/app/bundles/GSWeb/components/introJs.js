import { introJs } from 'intro.js';

let doneStep = {
  element: '.school-name-container',
  highlightClass: 'no-highlight',
  intro: '<img alt="" height="42" src="http://orangestripes.com/gschool/owl/owl-2-copy-4.png" style="float:left" width="39"><h1>&nbsp;All done!</h1></div><div class="inmplayer-template-content"><br/><p>Thank you for taking time to walk through our new profiles.&nbsp;<br>&nbsp;</p><div class="inmplayer-button" onclick="inline_manual_player.deactivate()">Start exploring this school</div></div>'
};

let otherSteps = [
  {
    element: '#hero',
    intro: 'Here you\'ll find general information about this school, including our GreatSchools Summary Rating, community reviews, school contact info and more.'
  },
  {
    element: '.gs-rating-with-label',
    intro: 'The GreatSchools rating provides a quick snapshot of this school\'s quality compared to other schools in the state.',
    position: 'top',
    highlightClass: 'highlight-dark'
  },
  {
    element: '.toc-container-box .toc-section-title',
    intro: 'From here you can see quick links to information about the school.',
    position: 'top'
  },
  {
    element: '#cta',
    intro: '<div><p>From here you can...</p><ul><li>Write a review of a school</li><li>Save the school to get email updates</li><li>Compare nearby high performing schools</li></ul></div>',
    position: 'top'
  },
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
  },
  {
    element: '#Neighborhood .title',
    intro: 'Here you can find this school on a map, including a link to see the school’s attendance zone.',
    position: 'top'
  },
  {
    element: '#NearbySchools .title-bar',
    intro: 'Scroll through other nearby high-performing schools so you can better understand the education options in your area.',
    position: 'top',
  }
];

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

export function start() {
  // use jQuery to filter out elements that dont exist
  let filteredSteps = otherSteps.filter(function(obj) {
    return $(obj.element).length;
  });
  let allSteps = filteredSteps.concat([doneStep]);
  numberOfVisibleSteps = allSteps.length;

  intro = introJs().
    setOptions({
      showStepNumbers: false, 
      steps: filteredSteps.concat([doneStep]),
      hidePrev: true,
      hideNext: true,
      showProgress: false,
      skipLabel: 'cancel',
      overlayOpacity: 0
    }).
    onafterchange(onStepSeen).
    onexit(onExitTour)
  $(homesAndRentalsSelector).hide();
  intro.start();
}
