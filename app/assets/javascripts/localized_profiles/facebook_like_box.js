GS.facebook = GS.facebook || {};

GS.facebook.tryFacebookFallbackBehaviorOnInterval = function() {
  if ($('.js-fb-page-plugin')[0]) {
    jQuery(function () {
      var opts = {
        fbPagePluginDiv: jQuery('.js-fb-page-plugin').first(),
        fbPagePluginFallbackDiv: jQuery('.js-fb-page-plugin-fallback').first(),
        tooShortCounter: 0,
        justRightCounter: 0
      };

      opts.intervalId = window.setInterval(GS.facebook.checkIframeHeight.bind(undefined, opts, jQuery), 50);

      // Stop monitoring after at most 15 seconds. e.g. if Facebook failed to insert the iframe.
      window.setTimeout(function () {
        window.clearInterval(opts.intervalId);
      }, 15000);
    });
  }
};

GS.facebook.showFacebookSection = function() {
  var facebookSectionSelector = '#facebook-section';
  var facebookSectionDesktopAdId = 'School_OverviewFacebookAd';
  var facebookSectionMobileAdId = 'School_OverviewFacebookMobile_Ad';

  $(facebookSectionSelector).removeClass('dn').show();

  if($('#' + facebookSectionDesktopAdId).is(':visible')) {
    GS.ad.showAd(facebookSectionDesktopAdId);
  } else if ($('#' + facebookSectionMobileAdId).is(':visible')) {
    GS.ad.showAd(facebookSectionMobileAdId);
  }

  GS.facebook.tryFacebookFallbackBehaviorOnInterval();
};

/**
 * Monitors the height of the Facebook plugin iframe, and calls handleIframeTooShort if it consistently drops
 * below HEIGHT_CUTOFF, where consistently is defined as at least TOO_SHORT_LIMIT measurements.
 *
 * In addition, it stops monitoring if the iframe height is at least HEIGHT_CUTOFF for JUST_RIGHT_LIMIT
 * measurements.
 */
GS.facebook.checkIframeHeight = function(opts, $) {
  var $fbPagePluginDiv = opts.fbPagePluginDiv;
  var $fbPagePluginFallbackDiv = opts.fbPagePluginFallbackDiv;
  var TOO_SHORT_LIMIT = 5; // after this many short measurements, we'll take action
  var JUST_RIGHT_LIMIT = 20; // after this many good measurements, we'll stop checking
  var HEIGHT_CUTOFF = 30; // less than this many pixels is "too short"

  var height = $fbPagePluginDiv.find('iframe').height();

  if (height == null) {
    // nothing to do
  } else if (height < HEIGHT_CUTOFF) {
    if (opts.tooShortCounter++ > TOO_SHORT_LIMIT) {
      window.clearInterval(opts.intervalId);
      $fbPagePluginDiv.addClass('dn').hide();
      $fbPagePluginFallbackDiv.removeClass('dn').show();
    }
  } else if (opts.justRightCounter++ > JUST_RIGHT_LIMIT) {
    window.clearInterval(opts.intervalId);
  }
};