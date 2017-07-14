import { introJs } from 'intro.js';

let doneStep = {
  intro: '<img alt="" height="42" src="http://orangestripes.com/gschool/owl/owl-2-copy-4.png" style="float:left" width="39"><h1>&nbsp;All done!</h1></div><div class="inmplayer-template-content"><p>Thank you for taking time to walk through our new profiles.&nbsp;<br>&nbsp;</p><div class="inmplayer-button" onclick="inline_manual_player.deactivate()">Start exploring this school</div></div>'
};

let otherSteps = [
  {
    element: document.querySelector('#hero'),
    intro: 'Here you\'ll find general information about this school, including our GreatSchools Summary Rating, community reviews, school contact info and more.'
  },
  {
    element: document.querySelectorAll('.gs-rating-with-label')[0],
    intro: 'The GreatSchools rating provides a quick snapshot of this school\'s quality compared to other schools in the state.',
    position: 'auto',
    highlightClass: 'highlight-dark'
  },
  {
    element: document.querySelectorAll('.toc-container-box > .row')[0],
    intro: 'This section offers quick links to 3 categories of  information about this school.',
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
    element: $('#AdvancedCourses .module-header')[0],
    intro: 'This section looks how well this school is doing in encouraging a large number of its students to take advanced courses, both overall and within key subject areas.',
    position: 'top'
  },
  {
    element: $('#StudentProgress .module-header')[0],
    intro: 'The <strong>Student Progress Rating</strong> gives you a sense of how much academic improvement students at this school have made year-over-year (also known as “growth”) compared with other schools in the state.',
    position: 'top'
  },
  {
    element: '#Equityoverview .module-header',
    intro: 'The Equity Overview Rating looks at how well this school is serving the needs of diverse student groups relative to all its students, compared to other schools in the state.',
    position: 'top'
  },
  {
    element: '#EquityRaceEthnicity .module-header',
    intro: 'This section helps you understand how well a school is serving all of its students, looking at information like test scores and suspension rates for different racial and ethnic groups at this school.',
    position: 'top'
  },
  {
    element: '#EquityLowIncome .module-header',
    intro: 'This section looks at how well this school is serving its students from low-income families, looking at information like test scores and graduation rates.',
    position: 'top'
  },
  {
    element: '#EquityDisabilities .module-header',
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
    element: '#Neighborhood .overlay-container',
    intro: 'Here you can find this school on a map, including a link to see the school’s attendance zone.',
    position: 'top'
  },
  {
    element: '#NearbySchools',
    intro: 'Scroll through other nearby high-performing schools so you can better understand the education options in your area.',
    position: 'top',
  }
];

let intro = null;

const onStepSeen = function(targetElement) {
  let stepNum = intro._currentStep + 1;
  window.analyticsEvent('Profile', 'tutorial-public', stepNum);
}

export function start() {
  intro = introJs().
    setOptions({
      showStepNumbers: false, 
      // use jQuery to filter out elements that dont exist
      steps: otherSteps.filter(obj => $(obj.element).length).concat([doneStep]),
      hidePrev: true,
      hideNext: true,
      showProgress: false,
      skipLabel: 'cancel'
    }).
    onafterchange(onStepSeen)
  intro.start();
}
