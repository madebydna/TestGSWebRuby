import { viewport } from '../util/viewport';
import { throttle, debounce } from 'lodash';

var ctaProfileOffset;
var cta;
var header_un;
var transitionToMobile = 991;
var ctaParentHeight = 0;
var ctaParentWidth = 0;

var init = function () {
  cta = $('.js-profile-sticky');
  header_un = $('.header_un');
  // only init when cta is on the page. :)
  if (isCTADefined()) {
    $(window).on('scroll', throttle(recalculateCTAResize, 50));
    $(window).on('resize', debounce(recalculateCTAResize, 100));

    recalculateCTAResize();
  }
};

var recalculateCTAResize = function () {
  if (isDesktopWidth()) {
    setCTAProfileOffset();
    setCTARowHeightToParent();
    setCTARowWidthToParent();
    manageFixedPositions();
  }
};

var manageFixedPositions = function () {
  if (isDesktopWidth()) {
    header_un.removeClass('dn');
    if (isScrollAboveTop()) {
      if (scrollBelowBottom()) {
        alignToBottom();
      } else {
        alignFixedTop();
      }
    } else {
      alignDefault();
    }
  }
};

// is cta is defined on page
var isCTADefined = function () {
  return (cta.val() !== undefined);
};

// setters
var setCTAProfileOffset = function () {
  ctaProfileOffset = cta.parent().offset().top;
};

var setCTARowHeightToParent = function () {
  ctaParentHeight = cta.parent().parent().height();
};

var setCTARowWidthToParent = function () {
  ctaParentWidth = cta.parent().width();
  cta.width(ctaParentWidth);
};

// branching
var isScrollAboveTop = function () {
  return (ctaProfileOffset <= $(window).scrollTop());
};

var isDesktopWidth = function () {
  return (viewport().width > transitionToMobile);
};

var scrollBelowBottom = function () {
  var ctaBottomOffset = ctaParentHeight - cta.height() + ctaProfileOffset - 30;
  return (ctaBottomOffset <= $(window).scrollTop());
};

// align cta for each case
var alignToBottom = function () {
  cta.removeClass('fixed-top').removeClass('non-fixed-top').removeClass('dn').addClass('align-bottom');
};

var alignFixedTop = function () {
  cta.removeClass('non-fixed-top').removeClass('align-bottom').removeClass('dn').addClass('fixed-top');
};

var alignDefault = function () {
  cta.removeClass('fixed-top').removeClass('align-bottom').addClass('non-fixed-top').addClass('dn');
};

export { init };


