import {
  onAdFilled as onMobileOverlayAdFilled,
  onAdNotFilled as onMobileOverlayAdNotFilled
} from 'components/ads/mobile_overlay';
import log from 'util/log';

let $ = window.jQuery;
window.googletag = window.googletag || {};
googletag.cmd = googletag.cmd || [];
window.gon = window.gon || {};
let advertising_enabled = gon.advertising_enabled;
window.GS = window.GS || {};
GS.ad = GS.ad || {};
GS.ad.slot = GS.ad.slot || {};

let slots = GS.ad.slot;
let shownArray = [];
let functionSlotDefinitionArray = [];
let functionAdShowArray = [];
let googleId = '/1002894/';
let slotTimers = {};



const slotRenderedHandler = function(event) {
  if (event.isEmpty) {
    // Hide the entire containing div (which includes the ad div and the ghost text) as no ad has been rendered
    jQuery('.js-' + event.slot.getSlotElementId() + '-wrapper').hide();
    let $wrapper = $('.js-' + event.slot.getSlotElementId() + '-wrapper');
    if($wrapper.hasClass('mobile-ad-sticky-bottom')) {
      onMobileOverlayAdNotFilled();
    }
  } else {
    let $wrapper = $('.js-' + event.slot.getSlotElementId() + '-wrapper');
    if($wrapper.hasClass('mobile-ad-sticky-bottom')) {
      onMobileOverlayAdFilled();
    }
    // Show the ghost text as an ad is rendered
    jQuery('.js-' + event.slot.getSlotElementId() + '-wrapper .advertisement-text').removeClass('dn').show();
  }
};

//////////////////////////////////////////////////////////////////////
//
//   Populates the ads that are visible on the page.
//   All ad slots should have the gs_ad_slot class
//   Set either visible or hidden using bootstrap hidden- or visible- classes
//   Uses Adobe Audience Manager for setTargeting and gon.ad_set_targeting for setTargeting - both page level
//
/////////////////////////////////////////////////////////////////////////////

const loadGpt = function() {
  (function () {
    var gads = document.createElement('script');
    gads.async = true;
    gads.type = 'text/javascript';
    var useSSL = "https:" == document.location.protocol;
    gads.src = (useSSL ? "https:" : "http:") + "//www.googletagservices.com/tag/js/gpt.js";
    var node = document.getElementsByTagName('script')[0];
    node.parentNode.insertBefore(gads, node);
  })();
}

const init = function() {
  loadGpt();
  var dfp_slots = $(".gs_ad_slot").filter(":visible,[data-ad-defer-render]");
  if (gon.advertising_enabled && dfp_slots.length > 0) {
    googletag.cmd.push(function () {
      //    Remove after ab test
      if (!$.isEmptyObject(gon.ad_set_channel_ids)) {
        googletag.pubads().set("adsense_channel_ids", gon.ad_set_channel_ids);
      }

      $(dfp_slots).each(function () {
        defineSlot($(this));
      });

      while (functionSlotDefinitionArray.length > 0) {
        (functionSlotDefinitionArray.shift())();
      }

      setPageLevelTargeting();
      googletag.pubads().collapseEmptyDivs();
      googletag.pubads().addEventListener('slotRenderEnded', slotRenderedHandler);
      googletag.enableServices();

      $(dfp_slots).each(function() {
        showOrDefer($(this));
      });

      while (functionAdShowArray.length > 0) {
        (functionAdShowArray.shift())();
      }
    });
  }
};

const getSizeMappings = function() {
  return {
    'box_desktop_not_tall':  googletag.sizeMapping().
            addSize([992, 300], [[300, 250]]).
            build(),
    'box': googletag.sizeMapping().
            addSize([300, 600], [[300, 600], [300, 250]]).
            addSize([0, 0], [[300, 250]]).
            build(),
    'box_or_tall': googletag.sizeMapping().
            addSize([992, 300], [[300, 600], [300, 250]]).
            addSize([768, 120], [[728, 90]]).
            addSize([0, 0], [[300, 250]]).
            build(),
    'banner_tall': googletag.sizeMapping().
          addSize([1200, 300], [[1140, 250], [1140, 100],[728, 90]]).
          addSize([1052, 300], [[970, 250], [970, 100],[728, 90]]).
          addSize([865, 300], [[728, 90],[630, 250],[630, 100]]).
          addSize([690, 300], [[630, 250],[630, 100],[300, 250],[320, 50]]).
          addSize([0, 0], [[300, 250],[300, 100],[320, 50]]).
          build(),
    'banner_short': googletag.sizeMapping().
          addSize([1200, 300], [[1140, 250], [1140, 100],[728, 90]]).
          addSize([1052, 300], [[970, 250], [970, 100],[728, 90]]).
          addSize([865, 300], [[728, 90],[630, 250],[630, 100]]).
          addSize([690, 300], [[630, 250],[630, 100],[300, 250],[320, 50]]).
          addSize([0, 0], [[300, 250],[300, 100],[320, 50]]).
          build(),
    'in_content': googletag.sizeMapping().
          addSize([1200, 208], [[728,90], [630,250]]).
          addSize([1080, 290], [[630, 250], [300,250]]).
          addSize([0, 0], [300, 250]).
          build(),
    'thin_banner': googletag.sizeMapping().
            addSize([768, 120], [[728, 90]]).
            addSize([0, 0], [[320, 50]]).
            build(),
    'mobile_overlay': googletag.sizeMapping().
            addSize([768, 0], []).
            addSize([0, 0], [[320, 100], [320, 50]]).
            build(),
    'thin_banner_or_box': googletag.sizeMapping().
            addSize([992, 300], [[728, 90], [970, 250]]).
            addSize([768, 120], [[728, 90]]).
            addSize([0, 0], [[320, 50], [300, 250]]).
            build(),
      'interstitial': googletag.sizeMapping().
            addSize([640, 480], [[640, 800], [300, 137]]).
            addSize([0, 0], [[300, 137]]).
            build()
  };
};

const defineSlot = function($adSlot) {
  var sizeMappingMap = getSizeMappings();
  let slot = googletag.defineSlot(
    getSlotName($adSlot),
    getDimensions($adSlot),
    getDivId($adSlot)
  );
  var sizeMapping = sizeMappingMap[$adSlot.attr("data-ad-setting")];
  if (sizeMapping) {
    slot = slot.defineSizeMapping(sizeMapping);
  }
  slots[getDivId($adSlot)] = slot.addService(googletag.pubads());
};

const getDivId = function (obj) {
  return obj.attr('id');
};

const getDimensions = function (obj) {
  try {
    return JSON.parse(obj.attr('data-ad-size'));
  } catch (e) {
    log('Error parsing ad dimensions for ' + obj.attr('id'));
  }
};

const getSlotName = function (obj) {
  return googleId + obj.attr('data-dfp');
};

const setPageLevelTargeting = function () {
  // being set in localized_profile_controller - ad_setTargeting_through_gon
  // sets all targeting based on what is set in the controller
  if ($.isEmptyObject(gon.ad_set_targeting)) {
    log("gon setTargeting is empty for advertising");
  }
  else {
    $.each(gon.ad_set_targeting, function (key, value) {
      googletag.pubads().setTargeting(key, value);
    });
  }
};

const showOrDefer = function($adSlot) {
  var deferRender = $adSlot.data('ad-defer-render') != undefined;
  if (!deferRender) {
    showAd(getDivId($adSlot));
  }
};

const showAd = function (divId) {
  if ($.inArray(divId, shownArray) == -1) {
    googletag.cmd.push(function () {
      shownArray.push(divId);
      googletag.display(divId);
    });
  }
  else {
    var lastRefreshedTime = slotTimers[divId];
    if (lastRefreshedTime === undefined || (new Date().getTime() - lastRefreshedTime >= 1000)) {
      slotTimers[divId] = new Date().getTime();
      googletag.pubads().refresh([slots[divId]]);
    }
  }
};

const wrapFunction = function(fn, context, params) {
  return function() {
    fn.apply(context, params);
  };
};

const addToAdSlotDefinitionArray = function (fn, context, params) {
  functionSlotDefinitionArray.push(wrapFunction(fn, context, params));
};

const addToAdShowArray = function (fn, context, params) {
  functionAdShowArray.push(wrapFunction(fn, context, params));
};

const checkMessageOrigin = function(origin) {
  return typeof origin === 'string' && (origin.match(/greatschools\.org$/) || origin.match(/googlesyndication\.com$/) || origin.match(/doubleclick\.net$/));
};

const handleGhostTextMessages = function(event) {
  if (typeof event !== 'undefined' && checkMessageOrigin(event.origin) && typeof event.data !== 'undefined' && typeof event.data.ghostText == 'string') {
    jQuery('iframe').each(function() {
      if (this.getAttribute('name') && window.frames[this.getAttribute('name')] == event.source) {
        var $adSlotDiv = jQuery(this).parents('.gs_ad_slot');
        var slotName = $adSlotDiv.attr('id');
        $adSlotDiv.parents('.js-' + slotName + '-wrapper').find('.advertisement-text').text(event.data.ghostText);
      }
    });
  }
};

const addCompfilterToGlobalAdTargetingGon = function () {
  var randomCompFilterValue = (Math.floor(Math.random()*4)+1).toString();
  if (!gon.ad_set_targeting) {
    gon.ad_set_targeting = {};
  }
  gon.ad_set_targeting['compfilter'] = randomCompFilterValue;
}


window.addEventListener('message', handleGhostTextMessages, false);

///// examples
// desktop
//<div class="gs_ad_slot visible-lg visible-md" id="div-gpt-ad-1397603538853-0" data-ad-size="[[300,600],[300,250]]" style="width: 300px;" data-dfp="School_Overview_Snapshot_300x250"></div>

// mobile
//<div class="gs_ad_slot visible-sm visible-xs" id="div-gpt-ad-1397602726713-0" data-ad-size="[300,250]" style="width: 300px;" data-dfp="School_Overview_Mobile_Snapshot_300x250"></div>



function enableAdCloseButtons() {
  $('.js-closable-ad').on('click', '.close', function(element) {
    $(this).closest('.js-closable-ad').remove();
  });
}

GS.ad.addCompfilterToGlobalAdTargetingGon = addCompfilterToGlobalAdTargetingGon;
GS.ad.showAd = showAd;
GS.ad.slotRenderedHandler = slotRenderedHandler;
GS.ad.init = init;
export { init, showAd, enableAdCloseButtons }

