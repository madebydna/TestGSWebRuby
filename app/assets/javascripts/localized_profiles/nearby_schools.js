GS = GS || {};

GS.nearbySchools = (function() {
  var NEARBY_SCHOOLS_MODULE_SELECTOR = '.js-nearbySchoolsModule';
  var NEARBY_SCHOOLS_SELECTOR        = '.js-nearbySchoolsCarousel';
  var NEARBY_SCHOOLS_HIDE_SELECTOR   = '.js-nearbySchoolsHide';
  var WHITE_SPACE_DIV_SELECTOR       = '.js-whiteSpaceDiv';
  var WHITE_SPACE_DIV                = "<div class='js-whiteSpaceDiv invert-colors'></div>";
  var category                       = 'Nearby schools sticky';
  var action                         = 'Show module';
  var label                          = undefined;
  var value                          = undefined;
  var nonInteractive                 = true;

  var initialize = function() {
    initializeShowModuleListener();
  };

  var initializeShowModuleListener = function() {
    if (!shouldHideNearbySchools()) {
      $(document).on('scroll', function() {
        $(this).off('scroll');
        analyticsEvent(category, action, label, value, nonInteractive);
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
      prevArrow: false,
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

  var shouldHideNearbySchools = function() {
    return $.cookie('hideNearbySchools') === 'true'
  };

  var setHideNearbySchoolsCookie = function() {
    $.cookie('hideNearbySchools', 'true', {expires: 1, path: '/' });
  };

  return {
    initialize: initialize,
  };
})();
