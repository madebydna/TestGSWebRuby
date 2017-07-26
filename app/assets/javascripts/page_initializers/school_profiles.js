$(function() {

  GS.ad.addCompfilterToGlobalAdTargetingGon();

  // used by test scores in school profiles
  $('body').on('click', '.js-test-score-details', function () {
    var grades = $(this).closest('.bar-graph-display').parent().find('.grades');
    if(grades.css('display') == 'none') {
      grades.slideDown();
      $(this).find('span').removeClass('rotate-text-270');
    }
    else{
      grades.slideUp();
      $(this).find('span').addClass('rotate-text-270');
    }
  });

  // for historical ratings
  $('body').on('click', '.js-historical-button', function () {
    var historical_data = $(this).closest('.js-historical-module').find('.js-historical-target');
    if(historical_data.css('display') == 'none') {
      historical_data.slideDown();
      $(this).find('div').html(GS.I18n.t('Hide past ratings'));
      analyticsEvent('Profile', 'Historical Ratings', null, null, true);
    }
    else{
      historical_data.slideUp();
      $(this).find('div').html(GS.I18n.t('Past ratings'));
    }
  });

  GS.search.autocomplete.searchAutocomplete.init();

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

});
