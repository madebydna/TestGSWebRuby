import ReactOnRails from "react-on-rails";
import District from "./react_components/community/district";
import City from "./react_components/community/city";
import SearchBoxWrapper from 'react_components/search_box_wrapper';
import withViewportSize from 'react_components/with_viewport_size';
import TopSchoolsStateful from 'react_components/community/top_schools_stateful';
import CsaTopSchools from 'react_components/community/csa_top_schools';
import SchoolBrowseLinks from 'react_components/community/school_browse_links';
import AcademicsDataModule from 'react_components/community/academics_data_module';
import Students from 'react_components/community/students';
import DistrictsInState from 'react_components/community/districts_in_state';
import RecentReviews from 'react_components/community/recent_reviews';
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
const StudentsWrapper = withViewportSize({ propName: 'size' })(Students);
const DistrictsInStateWrapper = withViewportSize({ propName: 'size' })(DistrictsInState);
const RecentReviewsWrapper = withViewportSize({ propName: 'size' })(RecentReviews);


ReactOnRails.register({
  District,
  City,
  SearchBoxWrapper,
  TopSchoolsStatefulWrapper,
  CsaTopSchoolsWrapper,
  SchoolBrowseLinksWrapper,
  AcademicsDataModuleWrapper,
  StudentsWrapper,
  DistrictsInStateWrapper,
  RecentReviewsWrapper,
  Ad
});

$(() => {
  commonPageInit();
  $('body').on('click', '.js-test-score-details', function () {
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
  // keepInViewport('.toc', {
  //   elementsAboveFunc: () => [].slice.call(window.document.querySelectorAll('.header_un')),
  //   elementsBelowFunc: () => [].slice.call(window.document.querySelectorAll('.footer')),
  //   setTop: true,
  //   setBottom: true
  // });

  $('.state-body .toc li').on('click', function(e) {
    let elem = e.currentTarget;
    if (elem.nodeName === 'LI') {
      let anchor = elem.getAttribute('anchor');
      scrollToElement(anchor, ()=>{}, -60);
      }
    }
  );

  $(window).on('scroll', throttle(function() {
    const tocElements = [...document.querySelectorAll('.module-section')].filter(ele => isScrolledInViewport(ele));
    const selectedToc = tocElements.length > 0 ? tocElements[0].id : [];

    window.document.querySelectorAll('.state-body .toc li').forEach(element => {
      if (element.getAttribute('anchor') === `#${selectedToc}`) {
        element.classList.add('selected');
      } else {
        element.classList.remove('selected');
      }
    });
  }, 100));

  initAdvertising();

});