import { viewport } from '../util/viewport';
//TODO: import jQuery

var ctaProfileOffset;
var cta;
var transitionToMobile = 991;

var init = function () {
  cta = $('.js-profile-sticky');
  // only init when cta is on the page. :)
  if (isCTADefined()) {
    $(window).on('scroll', _.throttle(recalculateCTAResize, 50));
    $(window).on('resize', _.debounce(recalculateCTAResize, 100));

    recalculateCTAResize();
  }
};

var recalculateCTAResize = function () {
  setCTAProfileOffset();
  if (isDesktopWidth()) {
    setCTARowHeightToParent();
  } else {
    setCTARowToDefault();
  }
  manageFixedPositions();
};

var manageFixedPositions = function () {
  if (isDesktopWidth()) {
    if (isScrollAboveTop()) {
      if (scrollBelowBottom()) {
        alignToBottom();
      } else {
        alignFixedTop();
      }
    } else {
      alignDefault();
    }
  } else {
    alignMobile();
  }
};

// is cta is defined on page
var isCTADefined = function () {
  return (cta.val() !== undefined);
};

// setters
var setCTAProfileOffset = function () {
  ctaProfileOffset = cta.parent().offset().top + 30;
};

var setCTARowHeightToParent = function () {
  cta.parent().height(cta.parent().parent().height());
};

var setCTARowToDefault = function () {
  cta.parent().height('auto');
};

// branching
var isScrollAboveTop = function () {
  return (ctaProfileOffset <= $(window).scrollTop());
};

var isDesktopWidth = function () {
  return (viewport().width > transitionToMobile);
};

var scrollBelowBottom = function () {
  var ctaBottomOffset = cta.parent().height() - cta.height() + ctaProfileOffset - 30;
  return (ctaBottomOffset <= $(window).scrollTop());
};

// align cta for each case
var alignToBottom = function () {
  cta.removeClass('fixed-top').removeClass('non-fixed-top').addClass('align-bottom');
};

var alignFixedTop = function () {
  cta.removeClass('non-fixed-top').removeClass('align-bottom').addClass('fixed-top');
};

var alignDefault = function () {
  cta.removeClass('fixed-top').removeClass('align-bottom').addClass('non-fixed-top');
};

var alignMobile = function () {
  cta.removeClass('fixed-top').removeClass('align-bottom').removeClass('non-fixed-top');
};

export { init };


