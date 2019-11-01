import { throttle } from 'lodash';

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
const refreshAdOnScroll = function(adDivId, containerSelector, minHeight) {
  let eventName = 'scroll.adRefresh.' + adDivId;
  let scrollListenFrequency = 500;

  
  let refreshAdIfEligible = function() {
    if ((GS.ad.slotViewability[adDivId] || {})['currentIndirectAd']) {
      return;
    }
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

  $(window).on(eventName, throttle(refreshAdIfEligible, scrollListenFrequency));
};

export default refreshAdOnScroll;
