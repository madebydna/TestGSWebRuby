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
  return (rightRailProfileOffset <= ($(window).scrollTop() + 40));
};

var isDesktopWidth = function () {
  return (viewport().width > transitionToMobile);
};

var scrollBelowBottom = function () {
  var rightRailBottomOffset = rightRail.parent().height() - rightRail.height() + rightRailProfileOffset - 30;
  return (rightRailBottomOffset <= ($(window).scrollTop()) +20);
};

// align rightRail for each case
var alignToBottom = function () {
  rightRail.removeClass('fixed-top-right-bar').removeClass('non-fixed-top').addClass('align-bottom');
};

var alignFixedTop = function () {
  rightRail.removeClass('non-fixed-top').removeClass('align-bottom').addClass('fixed-top-right-bar');
};

var alignDefault = function () {
  rightRail.removeClass('fixed-top-right-bar').removeClass('align-bottom').addClass('non-fixed-top');
};

export { init };


