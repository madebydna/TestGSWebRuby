import { viewport } from '../util/viewport';
import { throttle, debounce } from 'lodash';
//TODO: import jQuery

var rightRailProfileOffset;
var rightRail;
var transitionToMobile = 991;

var init = function () {
  rightRail = $('.js-sticky-right-rail');
  // only init when rightRail is on the page. :)
  if (isrightRailDefined()) {
    $(window).on('scroll', throttle(recalculaterightRailResize, 50));
    $(window).on('resize', debounce(recalculaterightRailResize, 100));

    recalculaterightRailResize();
  }
};

var recalculaterightRailResize = function () {
  setrightRailProfileOffset();
  if (isDesktopWidth()) {
    setrightRailRowHeightToParent();
  } else {
    setrightRailRowToDefault();
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

// is rightRail is defined on page
var isrightRailDefined = function () {
  return (rightRail.val() !== undefined);
};

// setters
var setrightRailProfileOffset = function () {
  rightRailProfileOffset = rightRail.parent().offset().top + 30;
};

var setrightRailRowHeightToParent = function () {
  rightRail.parent().height(rightRail.parent().parent().height());
};

var setrightRailRowToDefault = function () {
  rightRail.parent().height('auto');
};

// branching
var isScrollAboveTop = function () {
  return (rightRailProfileOffset <= $(window).scrollTop());
};

var isDesktopWidth = function () {
  return (viewport().width > transitionToMobile);
};

var scrollBelowBottom = function () {
  var rightRailBottomOffset = rightRail.parent().height() - rightRail.height() + rightRailProfileOffset - 30;
  return (rightRailBottomOffset <= $(window).scrollTop());
};

// align rightRail for each case
var alignToBottom = function () {
  rightRail.removeClass('fixed-top').removeClass('non-fixed-top').addClass('align-bottom');
};

var alignFixedTop = function () {
  rightRail.removeClass('non-fixed-top').removeClass('align-bottom').addClass('fixed-top');
};

var alignDefault = function () {
  rightRail.removeClass('fixed-top').removeClass('align-bottom').addClass('non-fixed-top');
};

var alignMobile = function () {
  rightRail.removeClass('fixed-top').removeClass('align-bottom').removeClass('non-fixed-top');
};

export { init };


