import { viewport } from '../util/viewport';
import { throttle, debounce } from 'lodash';

var ctaProfileOffset;
var ctaMobileProfileOffset;
var ctaMobile;
var header_un;
var transitionToMobile = 991;
var oldCTATop = 0;

var init = function () {
  ctaMobile = $('.js-profile-sticky-mobile');
  header_un = $('.header_un');
  // only init when cta is on the page. :)
  if (isCTADefined()) {
    $(window).on('scroll', throttle(recalculateCTAResize, 50));
    $(window).on('resize', debounce(recalculateCTAResize, 100));

    recalculateCTAResize();
  }
};

var recalculateCTAResize = function () {
  if (isMobileWidth()) {
    setCTAProfileOffset();
    setCTAMobileHeight();
    setCTAMobileWidth();
    manageFixedPositions();
  }
};

var manageFixedPositions = function () {
  if (isMobileWidth()) {
    if ( isMobileScrollAboveTop()){
      alignFixedTop();
    }
    else {
      alignMobileDefault();
    }
  }
};

// is cta is defined on page
var isCTADefined = function () {
  return (ctaMobile.val() !== undefined);
};

var isMobileScrollAboveTop = function () {
  return (ctaMobileProfileOffset <= $(window).scrollTop());
};

var isMobileWidth = function () {
  return (viewport().width <= transitionToMobile);
};



var setCTAProfileOffset = function () {
  ctaProfileOffset = ctaMobile.parent().offset().top;
};

var setCTAMobileHeight = function () {
  ctaMobileProfileOffset = $('#hero').offset().top + $('#hero').height();
};

var setCTAMobileWidth= function () {
  ctaMobile.width($(window).width());
};



var alignFixedTop = function () {
  // console.log("oldCTATop < $(window).scrollTop(): " +oldCTATop+" :  "+ $(window).scrollTop());
  // if (oldCTATop < $(window).scrollTop()) {
  //   console.log("oldCTATop < $(window).scrollTop(): true");
    header_un.addClass('dn');
    ctaMobile.removeClass('non-fixed-top').removeClass('align-bottom').removeClass('dn').addClass('fixed-top');
  // }
  // else{
  //   console.log("oldCTATop < $(window).scrollTop(): false");
  //   header_un.removeClass('dn');
  //   ctaMobile.addClass('dn');
  // }
  // oldCTATop = $(window).scrollTop();
};

var alignMobileDefault = function () {
  ctaMobile.removeClass('fixed-top').addClass('non-fixed-top').removeClass('dn');
  header_un.removeClass('dn');
};


export { init };


