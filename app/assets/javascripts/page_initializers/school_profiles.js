$(function() {

  GS.ad.addCompfilterToGlobalAdTargetingGon();
  GS.handlebars.registerPartials();
  GS.handlebars.registerHelpers();
  GS.graphs.subgroupCharts.generateSubgroupPieCharts();
  GS.util.BackToTop.init();

  $('.js-nearby-toggle').find('button').on('click', function() {
    var $this = $(this);
    $this.addClass('active');
    $this.siblings().removeClass('active');

    var $contentPane = $('.js-nearby-content');
    $contentPane.children().addClass('dn').filter('[data-target="' + $this.data('target') + '"]').removeClass('dn');
  });

  $('.js-send-me-updates-button-footer').on('click', function () {
    if (GS.schoolNameFromUrl() === undefined || GS.stateAbbreviationFromUrl() === undefined ) {
      GS.sendUpdates.signupAndGetNewsletter();
    } else {
      var state = GS.stateAbbreviationFromUrl();
      var schoolId = GS.schoolIdFromUrl();
      GS.sendUpdates.signupAndFollowSchool(state, schoolId);
    }
  });

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

  $('.js-followThisSchool').on('click', function () {
    var state = GS.stateAbbreviationFromUrl();
    var schoolId = GS.schoolIdFromUrl();
    GS.sendUpdates.signupAndFollowSchool(state, schoolId);
  });

  try {
    $('.neighborhood img[data-src]').unveil(300, function() {
      $(this).width('100%')
    });
  } catch (e) {}
  try {
    $('.innovate-logo').unveil(300);
  } catch (e) {}

  (function() {
    /**
     * Refreshes an ad exactly once when the user scrolls past 50% in some container.
     * Requires the container to be at least minHeight. If the container ever grows
     * to exceed minHeight, then the ad would immediately be eligible for refresh if
     * the user is scrolled > 50% of the way down. Once the ad is refreshed once, there
     * will be no further refreshes.
     *
     * @param adDivId div ID where the ad is defined.
     * @param containerSelector Selector to identify the container
     * @param minHeight Minimum height for the container
     */
    var refreshAdOnScroll = function(adDivId, containerSelector, minHeight) {
      var eventName = 'scroll.adRefresh.' + adDivId;
      var scrollListenFrequency = 500;

      var refreshAdIfEligible = function() {
        var $container = $(containerSelector);
        var $window = $(window);
        var contentHeight = $container.height();
        var offset = $container.offset().top;
        if (contentHeight >= minHeight) {
          var halfwayDown = offset + (contentHeight / 2);
          if ($window.scrollTop() > halfwayDown) {
            $window.off(eventName);
            GS.ad.showAd(adDivId);
          }
        }
      };

      $(window).on(eventName, _.throttle(refreshAdIfEligible, scrollListenFrequency));
    };

    refreshAdOnScroll('Profiles_First_Ad', '.static-container', 1200);
  })();

  $(function() {
    $('.rating-container__title').each(function() {
      var $elem = $(this);
      var minWidth = 1200;
      GS.fixToTopWhenBelowY(
        $elem,
        function($elem){
          return $elem.parent().offset().top - 20;
        },
        function($elem){
          return $elem.parent().offset().top + $elem.parent().parent().parent().height() - 50 - $elem.height();
        },
        function() {
          return viewport().width >= minWidth;
        }
      );
    });
  });

});
