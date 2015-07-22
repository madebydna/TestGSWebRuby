GS.facebook = GS.facebook || {};

/**
 * Monitors the height of the Facebook plugin iframe, and calls handleIframeTooShort if it consistently drops
 * below HEIGHT_CUTOFF, where consistently is defined as at least TOO_SHORT_LIMIT measurements.
 *
 * In addition, it stops monitoring if the iframe height is at least HEIGHT_CUTOFF for JUST_RIGHT_LIMIT
 * measurements.
 */
GS.facebook.checkIframeHeight = function(opts, $) {
  var $fbPagePluginDiv = opts.fbPagePluginDiv;
  var schoolName = opts.schoolName;
  var fbUrl = opts.fbUrl;
  var TOO_SHORT_LIMIT = 5; // after this many short measurements, we'll take action
  var JUST_RIGHT_LIMIT = 20; // after this many good measurements, we'll stop checking
  var HEIGHT_CUTOFF = 30; // less than this many pixels is "too short"

  var height = $fbPagePluginDiv.find('iframe').height();

  if (height == null) {
    // nothing to do
  } else if (height < HEIGHT_CUTOFF) {
    if (opts.tooShortCounter++ > TOO_SHORT_LIMIT) {
      window.clearInterval(opts.intervalId);
      var $grandParent = $fbPagePluginDiv.parent().parent();
      // .text implicitly escapes the contents for HTML
      var $newContents = $('<div>').addClass('col-xs-12 tac')
        .append($('<h3>').addClass('mtn').text('Find out what parents are saying about ' + schoolName))
        .append($('<a>').attr('target', '_blank').attr('href', fbUrl).text(fbUrl));
      $grandParent.children().not('.js-nohide').addClass('dn'); // hide existing contents of Facebook module, but not ads
      $grandParent.prepend($newContents); // prepend a new, visible child linking directly to the FB URL
    }
  } else if (opts.justRightCounter++ > JUST_RIGHT_LIMIT) {
    window.clearInterval(opts.intervalId);
  }
};