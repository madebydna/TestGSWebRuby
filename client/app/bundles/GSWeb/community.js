/* global $, ReactOnRails */
import ReactOnRails from "react-on-rails";
import SearchBoxWrapper from 'react_components/search_box_wrapper';
import withViewportSize from 'react_components/with_viewport_size';
import TopSchoolsStateful from 'react_components/community/top_schools_stateful';
import CsaTopSchools from 'react_components/community/csa_top_schools';
import CsaInfo from 'react_components/community/csa_info';
import SchoolBrowseLinks from 'react_components/community/school_browse_links';
import SummaryRating from 'react_components/community/summary_rating';
import GrowthRating from 'react_components/community/growth_rating';
import StemCourses from 'react_components/school_profiles/stem_courses';
import AcademicsDataModule from 'react_components/community/academics_data_module';
import Students from 'react_components/community/students';
import TeachersStaff from 'react_components/community/teachers_staff';
import Calendar from 'react_components/community/calendar';
import DistanceLearning from 'react_components/community/distance_learning';
import Finance from 'react_components/community/finance';
import Mobility from 'react_components/community/mobility';
import Zillow from 'react_components/community/zillow';
import Ad from 'react_components/ad';
import { scrollToElement } from 'util/scrolling';
import { keepInViewport, isScrolledInViewport } from 'util/viewport';
import { init as initAdvertising } from 'util/advertising';
import { throttle } from 'lodash';
import { enableAutoAnchoring, initAnchorHashUpdater } from './components/anchor_router';
import commonPageInit from './common';

const TopSchoolsStatefulWrapper = withViewportSize({ propName: 'size' })(TopSchoolsStateful);
const CsaTopSchoolsWrapper = withViewportSize({ propName: 'size' })(CsaTopSchools);
const SchoolBrowseLinksWrapper = withViewportSize({ propName: 'size' })(SchoolBrowseLinks);
const AcademicsDataModuleWrapper = withViewportSize({ propName: 'size' })(AcademicsDataModule);
const TeachersStaffWrapper = withViewportSize({ propName: 'size' })(TeachersStaff);
const AdWrapper = withViewportSize({ propName: 'size' })(Ad);

ReactOnRails.register({
  SearchBoxWrapper,
  TopSchoolsStatefulWrapper,
  CsaTopSchoolsWrapper,
  CsaInfo,
  SchoolBrowseLinksWrapper,
  SummaryRating,
  GrowthRating,
  StemCourses,
  AcademicsDataModuleWrapper,
  Students,
  TeachersStaffWrapper,
  Calendar,
  Finance,
  Mobility,
  Zillow,
  AdWrapper,
  DistanceLearning
});

$(() => {
  commonPageInit();

  // Todo animations like slidedown are tough to implement in vanilla javascript so leaving here
  //  until we figure out what to do with these
  $('body').on('click', '.js-test-score-details', function() {
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

  keepInViewport('.breadcrumbs-container', {
    initialTop: 60,
    setTop: true,
    setBottom: false
  });

  keepInViewport('.js-ad-hook', {
    elementsAboveFunc: () => [].slice.call(window.document.querySelectorAll('.header_un')),
    elementsBelowFunc: () => [].slice.call(window.document.querySelectorAll('.footer')),
    setTop: true,
    setBottom: true
  });

  const tocLinks = document.querySelectorAll(".toc li");
  tocLinks.forEach((link) => {
    link.addEventListener('click', (e) => {
      const elem = e.currentTarget;
      if (elem.nodeName === 'LI') {
        const anchor = elem.getAttribute('anchor');
        scrollToElement(`#${anchor}`, () => {
          history.replaceState(undefined, undefined, `#${anchor}`);
        }, -60);
      }
    });
  });

  function tocSelect() {
    const tocElements = [...document.querySelectorAll('.module-section')].filter(ele => isScrolledInViewport(ele));
    const selectedToc = tocElements.length > 0 ? tocElements[0].id : [];

    tocLinks.forEach(element => {
      if (element.getAttribute('anchor') === selectedToc) {
        element.classList.add('selected');
      } else {
        element.classList.remove('selected');
      }
    });
  }

  window.onscroll = throttle(() => { tocSelect(); }, 100);

  initAdvertising();

  initAnchorHashUpdater();

  enableAutoAnchoring({
    'Academics': '#academics .profile-module .panel',
    'academic_progress': '#academic_progress .profile-module',
    'student_progress': '#student_progress .profile-module',
    'TopSchools': '.top-school-module .profile-module',
    'advanced_courses': '#advanced_courses .panel',
    'students': '#students .students-module',
    'teachers-staff': '#teachers-staff .profile-module',
    'calendar': '#calendar',
    'finance': '#finance .profile-module',
    'mobility': '#mobility',
    'homes-and-rentals': '#homes-and-rentals',
    'reviews': '#reviews',
    'districts': '#districts .districts-in-community-module',
    'cities': '#cities .links-module',
    'neighboring-cities': '#neighboring-cities',
    'award-winning-schools': '#award-winning-schools',
    'CollegeSuccessAwardWinners': '.top-school-module .profile-module',
    'distance-learning': '#DistanceLearning'
  });

  $(() => {
    $('.js-shortened-text').each(function() {
      const $text = $(this);
      const extraText = $text.data('shortened-text-rest');
      $text.find('span').on('click', () => {
        $(this).hide();
        $text.html($text.html() + extraText);
      });
    });
   });
});