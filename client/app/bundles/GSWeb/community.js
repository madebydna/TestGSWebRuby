import ReactOnRails from "react-on-rails";
import District from "./react_components/community/district";
import City from "./react_components/community/city";
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
import DistrictsInState from 'react_components/community/districts_in_state';
import DistrictsInCity from 'react_components/community/districts_in_city';
import Calendar from 'react_components/community/calendar';
import Finance from 'react_components/community/finance';
import Mobility from 'react_components/community/mobility';
import XQSchoolBoardFinder from 'react_components/community/xq_school_board_finder';
import Zillow from 'react_components/community/zillow';
import RecentReviews from 'react_components/community/recent_reviews';
import CityLinks from 'react_components/community/city_links';
import Ad from 'react_components/ad';
import commonPageInit from './common';
import { scrollToElement } from 'util/scrolling';
import { keepInViewport, isScrolledInViewport } from 'util/viewport';
import { init as initAdvertising, enableAdCloseButtons, applyStylingToIFrameAd } from 'util/advertising';
import { throttle } from 'lodash';

const TopSchoolsStatefulWrapper = withViewportSize({ propName: 'size' })(TopSchoolsStateful);
const CsaTopSchoolsWrapper = withViewportSize({ propName: 'size' })(CsaTopSchools);
const SchoolBrowseLinksWrapper = withViewportSize({ propName: 'size' })(SchoolBrowseLinks);
const AcademicsDataModuleWrapper = withViewportSize({ propName: 'size' })(AcademicsDataModule);
const TeachersStaffWrapper = withViewportSize({ propName: 'size' })(TeachersStaff);
const DistrictsInStateWrapper = withViewportSize({ propName: 'size' })(DistrictsInState);
const DistrictsInCityWrapper = withViewportSize({ propName: 'size' })(DistrictsInCity);
const CityLinksWrapper = withViewportSize({ propName: 'size' })(CityLinks);
const AdWrapper = withViewportSize({ propName: 'size' })(Ad);


ReactOnRails.register({
  District,
  City,
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
  DistrictsInStateWrapper,
  DistrictsInCityWrapper,
  Calendar,
  Finance,
  Mobility,
  XQSchoolBoardFinder,
  Zillow,
  RecentReviews,
  CityLinksWrapper,
  AdWrapper
});

$(() => {
  commonPageInit();
  // Todo animations like slidedown are tough to implement in vanilla javascript so leaving here
  //  until we figure out what to do with these
  $('body').on('click', '.js-test-score-details', function () {
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
        }, -60);
      }
    });
  });

  function myFunction() {
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

  window.onscroll = throttle(function () {
    myFunction()
  }, 100);
  initAdvertising();
});