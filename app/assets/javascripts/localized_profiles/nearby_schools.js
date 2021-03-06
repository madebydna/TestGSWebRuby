GS = GS || {};

GS.nearbySchools = (function() {
  var NEARBY_SCHOOLS_MODULE_SELECTOR = '.js-nearbySchoolsModule';
  var NEARBY_SCHOOLS_SELECTOR        = '.js-nearbySchoolsCarousel';
  var NEARBY_SCHOOLS_HIDE_SELECTOR   = '.js-nearbySchoolsHide';
  var WHITE_SPACE_DIV_SELECTOR       = '.js-whiteSpaceDiv';
  var WHITE_SPACE_DIV                = "<div class='js-whiteSpaceDiv invert-colors'></div>";
  var category                       = 'Profile - Sticky nearby schools';
  var action                         = 'Show module';
  var label                          = undefined;
  var value                          = undefined;
  var nonInteractive                 = true;
  var stateAndSchool                 = gon.state + gon.school_id;

  var initialize = function() {
    initializeShowModuleListener();
  };

  var initializeShowModuleListener = function() {
    if (shouldShowNearbySchools()) {
      $(document).on('scroll', function() {
        $(this).off('scroll');
        analyticsEvent(category, action, label, value, nonInteractive);
        clearHideSchoolsCookie();
        $(NEARBY_SCHOOLS_MODULE_SELECTOR).slideDown(function() {
          addSpaceToBody();
        });
        initializeCarousel();
        initializeHideCarouselListener();
      });
    }
  }

  var initializeCarousel = function() {
    var $nearbySchoolsContainer = $(NEARBY_SCHOOLS_SELECTOR);
    $nearbySchoolsContainer.slick({
      prevArrow: '.js-prev',
      nextArrow: '.js-next',
    });
  };

  var initializeHideCarouselListener = function() {
    $(NEARBY_SCHOOLS_HIDE_SELECTOR).on('click', function() {
      $(this).off('click');
      $(NEARBY_SCHOOLS_MODULE_SELECTOR).slideUp();
      $(WHITE_SPACE_DIV_SELECTOR).slideUp();
      setHideNearbySchoolsCookie();
    });
  };

  var addSpaceToBody = function() {
    var nearbySchoolsModuleHeight = $(NEARBY_SCHOOLS_MODULE_SELECTOR).height();
    $('body').append(WHITE_SPACE_DIV);
    $(WHITE_SPACE_DIV_SELECTOR).css({height: nearbySchoolsModuleHeight});
  };

  // True if the gon variable that asserts that the module is on the
  // page (i.e. the current school has data for the module) is set and we are
  // not cookied to hide the module for school.
  var shouldShowNearbySchools = function() {
    // This gon variable is set in the HTML partial. If it is not set, we'll
    // default it to false, since that means the partial is not on the page.
    var moduleOnPage = gon.showNearbySchoolsSticky || false;
    return moduleOnPage && Cookies.get('hideNearbySchoolsFor') !== stateAndSchool;
  };

  var setHideNearbySchoolsCookie = function() {
    Cookies.set('hideNearbySchoolsFor', stateAndSchool, {expires: 1, path: '/' });
  };

  var clearHideSchoolsCookie = function() {
    Cookies.remove('hideNearbySchoolsFor', { path: '/' });
  };

  return {
    initialize: initialize,
  };
})();
