GS = GS || {};

GS.nearbySchools = (function() {
  var NEARBY_SCHOOLS_SELECTOR = '.js-nearbySchoolsCarousel';

  var initialize = function() {
    initializeCarousel();
  };

  var initializeCarousel = function() {
    var $nearbySchoolsContainer = $(NEARBY_SCHOOLS_SELECTOR);
    $nearbySchoolsContainer.slick({
      prevArrow: false,
      nextArrow: '.js-next',
    });
  };

  return {
    initialize: initialize,
  };
})();

$(function() {
  GS.nearbySchools.initialize();
});
