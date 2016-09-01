$(function() {

  GS.handlebars.registerPartials();
  GS.handlebars.registerHelpers();

  // When search bar added to universal nav, was required to init autocomplete on all pages
  // State specific pages have gon.state_abbr state and will initialize autocomplete with state
  // if state abbreviation is NOT set will init autocomplete without state.
  // All page specific initializing of autocomplete was removed
  //
  if (gon.state_abbr) {
    GS.search.autocomplete.searchAutocomplete.init(gon.state_abbr);
  }
  else {
    GS.search.autocomplete.searchAutocomplete.init();
  }

  (function() {
    var MINIMUM_HEIGHT_FOR_REFRESH = 1200;
    var AD_DIV_ID = 'Profiles_First_Ad';
    var REFRESH_LIMIT = 1;
    var EVENT_NAME = 'scroll.adRefresh';
    var SCROLL_LISTEN_FREQUENCY = 500;
    var refreshCount = 0;

    var setAdRefresh = function() {
      var $container = $('.static-container');
      var $window = $(window);
      var contentHeight = $container.height();
      var offset = $container.offset().top;
      if (contentHeight >= MINIMUM_HEIGHT_FOR_REFRESH) {
        var halfwayDown = offset + (contentHeight / 2);
        if ($window.scrollTop() > halfwayDown) {
          refreshCount += 1;
          if (refreshCount >= REFRESH_LIMIT) {
            $window.off(EVENT_NAME);
          }
          GS.ad.showAd(AD_DIV_ID);
        }
      }
    };

    $(window).on(EVENT_NAME, _.throttle(setAdRefresh, SCROLL_LISTEN_FREQUENCY));
  })();
});
