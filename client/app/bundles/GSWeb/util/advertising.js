import {
  onAdFilled as onMobileOverlayAdFilled,
  onAdNotFilled as onMobileOverlayAdNotFilled
} from 'components/ads/mobile_overlay';
import { capitalize } from 'util/i18n';
import log from 'util/log';
import { remove } from 'lodash';

const $ = window.jQuery;
window.googletag = window.googletag || {};
googletag.cmd = googletag.cmd || [];
window.gon = window.gon || {};
const advertising_enabled = gon.advertising_enabled;
window.GS = window.GS || {};
GS.ad = GS.ad || {};
GS.ad.slot = GS.ad.slot || {};

const slots = GS.ad.slot;
const shownArray = [];
const functionSlotDefinitionArray = [];
const functionAdShowArray = [];
const googleId = '/1002894/';
const slotTimers = {};

const slotIdFromName = (name, slotOccurrenceNumber = 1) => {
  const slotName = capitalize(name).replace(' ', '_');
  return `${slotName}${slotOccurrenceNumber}_Ad`;
};

const slotRenderedHandler = function(event) {
  if (event.slot.onRenderEnded) {
    event.slot.onRenderEnded({ isEmpty: event.isEmpty });
  } else if (event.isEmpty) {
    // Hide the entire containing div (which includes the ad div and the ghost text) as no ad has been rendered
    jQuery(`.js-${event.slot.getSlotElementId()}-wrapper`).hide();
    const $wrapper = $(`.js-${event.slot.getSlotElementId()}-wrapper`);
    if ($wrapper.hasClass('mobile-ad-sticky-bottom')) {
      onMobileOverlayAdNotFilled();
    }
  } else {
    const $wrapper = $(`.js-${event.slot.getSlotElementId()}-wrapper`);
    if ($wrapper.hasClass('mobile-ad-sticky-bottom')) {
      onMobileOverlayAdFilled();
    }
    if ($wrapper.hasClass('dn')) {
      $wrapper.removeClass('dn');
    }
    // Show the ghost text as an ad is rendered
    const $ghostText = $(`.js-${event.slot.getSlotId().getDomId()}-ghostText`); // wordpress
    if ($ghostText.length > 0) {
      $ghostText.appendTo($ghostText.parent());
      $ghostText.show();
    }
    jQuery(`.js-${event.slot.getSlotElementId()}-wrapper .advertisement-text`)
      .removeClass('dn')
      .show();
  }
};

// ////////////////////////////////////////////////////////////////////
//
//   Populates the ads that are visible on the page.
//   All ad slots should have the gs_ad_slot class
//   Set either visible or hidden using bootstrap hidden- or visible- classes
//   Uses Adobe Audience Manager for setTargeting and gon.ad_set_targeting for setTargeting - both page level
//
// ///////////////////////////////////////////////////////////////////////////

const loadGpt = function() {
  (function() {
    const gads = document.createElement('script');
    gads.async = true;
    gads.type = 'text/javascript';
    const useSSL = document.location.protocol == 'https:';
    gads.src = `${
      useSSL ? 'https:' : 'http:'
    }//www.googletagservices.com/tag/js/gpt.js`;
    const node = document.getElementsByTagName('script')[0];
    node.parentNode.insertBefore(gads, node);
  })();
};

let initialized = false;
const onInitializeFuncs = [];

const init = function() {
  loadGpt();
  const dfp_slots = $('.gs_ad_slot').filter(':visible,[data-ad-defer-render]');
  if (gon.advertising_enabled) {
    googletag.cmd.push(() => {
      //    Remove after ab test
      if (!$.isEmptyObject(gon.ad_set_channel_ids)) {
        googletag.pubads().set('adsense_channel_ids', gon.ad_set_channel_ids);
      }

      $(dfp_slots).each(function() {
        _defineSlot($(this));
      });

      while (functionSlotDefinitionArray.length > 0) {
        functionSlotDefinitionArray.shift()();
      }

      setPageLevelTargeting();
      googletag.pubads().collapseEmptyDivs();
      googletag
        .pubads()
        .addEventListener('slotRenderEnded', slotRenderedHandler);
      googletag.enableServices();

      $(dfp_slots).each(function() {
        showOrDefer($(this));
      });

      while (functionAdShowArray.length > 0) {
        functionAdShowArray.shift()();
      }
      while (onInitializeFuncs.length > 0) {
        onInitializeFuncs.shift()();
      }

      initialized = true;
    });
  }
};

const onInitialize = func =>
  initialized ? func() : onInitializeFuncs.push(func);

const getSizeMappings = function() {
  // for the addSize function, the first dimension specifies the browser size.  The second specifies the ad size
  return {
    box_desktop_not_tall: googletag
      .sizeMapping()
      .addSize([992, 300], [[300, 250]])
      .build(),
    box_or_tall: googletag
      .sizeMapping()
      .addSize([992, 300], [[300, 600], [300, 250]])
      .addSize([768, 120], [[728, 90]])
      .addSize([0, 0], [[300, 250]])
      .build(),
    banner_tall: googletag
      .sizeMapping()
      .addSize([1200, 300], [[1140, 250], [1140, 100], [728, 90]])
      .addSize([1052, 300], [[970, 250], [970, 100], [728, 90]])
      .addSize([865, 300], [[728, 90], [630, 250], [630, 100]])
      .addSize([690, 300], [[630, 250], [630, 100], [300, 250], [320, 50]])
      .addSize([0, 0], [[300, 250], [300, 100], [320, 50]])
      .build(),
    banner_short: googletag
      .sizeMapping()
      .addSize([1200, 300], [[1140, 250], [1140, 100], [728, 90]])
      .addSize([1052, 300], [[970, 250], [970, 100], [728, 90]])
      .addSize([865, 300], [[728, 90], [630, 250], [630, 100]])
      .addSize([690, 300], [[630, 250], [630, 100], [300, 250], [320, 50]])
      .addSize([0, 0], [[300, 250], [300, 100], [320, 50]])
      .build(),
    in_content: googletag
      .sizeMapping()
      .addSize([1200, 208], [[728, 90], [630, 250]])
      .addSize([1080, 290], [[630, 250], [300, 250]])
      .addSize([0, 0], [300, 250])
      .build(),
    thin_banner: googletag
      .sizeMapping()
      .addSize([768, 120], [[728, 90]])
      .addSize([0, 0], [[320, 50], [320, 100], [300, 250]])
      .build(),
    mobile_overlay: googletag
      .sizeMapping()
      .addSize([768, 0], [])
      .addSize([0, 0], [[320, 100], [320, 50]])
      .build(),
    thin_banner_mobile: googletag
      .sizeMapping()
      .addSize([0, 0], [[320, 100], [320, 50], [300, 250]])
      .build(),
    thin_banner_or_box: googletag
      .sizeMapping()
      .addSize([992, 300], [[728, 90], [970, 250]])
      .addSize([768, 120], [[728, 90]])
      .addSize([0, 0], [[320, 50], [300, 250]])
      .build(),
    prestitial: googletag
      .sizeMapping()
      .addSize([640, 480], [[640, 480]])
      .addSize([0, 0], [[300, 250]])
      .build(),
    interstitial: googletag
      .sizeMapping()
      .addSize([640, 480], [[640, 800], [300, 137]])
      .addSize([0, 0], [[300, 137]])
      .build(),
    box: googletag
      .sizeMapping()
      .addSize([0, 0], [[300, 250], [320, 100], [320, 50]])
      .build(),
    banner_top: googletag
      .sizeMapping()
      .addSize([1200, 300], [[1140, 250], [1140, 100], [728, 90]])
      .addSize([1052, 300], [[970, 250], [970, 100], [728, 90]])
      .addSize([865, 300], [[728, 90], [630, 250], [630, 100]])
      .addSize([690, 300], [[630, 250], [630, 100], [320, 50]])
      .addSize([0, 0], [[320, 100], [320, 50]])
      .build(),
    search_result_item: googletag
      .sizeMapping()
      .addSize([0, 0], [300,90])
      .build(),
    wide_or_box: googletag
      .sizeMapping()
      .addSize([768, 120], [[728, 90], [300, 250]])
      .addSize([0, 0], [[320, 50], [320, 100], [300, 250]])
      .build(),
  };
};

const _defineSlot = function($adSlot) {
  if (slots[getDivId($adSlot)]) {
    // already defined
    return;
  }
  const sizeMappingMap = getSizeMappings();
  let slot = googletag.defineSlot(
    getSlotName($adSlot),
    getDimensions($adSlot),
    getDivId($adSlot)
  );
  const sizeMapping = sizeMappingMap[$adSlot.attr('data-ad-setting')];
  if (sizeMapping) {
    slot = slot.defineSizeMapping(sizeMapping);
  }
  slots[getDivId($adSlot)] = slot.addService(googletag.pubads());
};

const defineAdOnce = ({
  slotOccurrenceNumber = 1,
  slotName,
  dimensions,
  sizeName,
  onRenderEnded
}) => {
  const divId = slotIdFromName(slotName, slotOccurrenceNumber);
  if (slots[divId]) {
    // already defined
    slots[divId].onRenderEnded = onRenderEnded;
    return;
  }
  const sizeMapping = getSizeMappings()[sizeName];
  let slot = googletag.defineSlot(googleId + slotName, dimensions, divId);
  if (sizeMapping) {
    slot = slot.defineSizeMapping(sizeMapping);
  }
  slot.onRenderEnded = onRenderEnded;
  slots[divId] = slot.addService(googletag.pubads());
};

const destroyAd = divId => {
  if (slots[divId]) {
    googletag.cmd.push(() => {
      googletag.destroySlots([slots[divId]]);
      delete slots[divId];
      remove(shownArray, id => id === divId);
    });
  }
};

const getDivId = function(obj) {
  return obj.attr('id');
};

const getDimensions = function(obj) {
  try {
    return JSON.parse(obj.attr('data-ad-size'));
  } catch (e) {
    log(`Error parsing ad dimensions for ${obj.attr('id')}`);
  }
};

const getSlotName = function(obj) {
  return googleId + obj.attr('data-dfp');
};

const setPageLevelTargeting = function() {
  // being set in localized_profile_controller - ad_setTargeting_through_gon
  // sets all targeting based on what is set in the controller
  if ($.isEmptyObject(gon.ad_set_targeting)) {
    if ($.isEmptyObject(GS.ad.adSetTargeting)) {
      log(
        'gon setTargeting and GS.ad.adSetTargeting are empty for advertising'
      );
    } else {
      // This is for WordPress which uses GS.ad.adSetTargeting (not having access to gon)
      $.each(GS.ad.adSetTargeting, (key, value) => {
        googletag.pubads().setTargeting(key, value);
      });
    }
  } else {
    $.each(gon.ad_set_targeting, (key, value) => {
      googletag.pubads().setTargeting(key, value);
    });
  }
};

const showOrDefer = function($adSlot) {
  const deferRender = $adSlot.data('ad-defer-render') != undefined;
  if (!deferRender) {
    showAd(getDivId($adSlot));
  }
};

const showAd = function(divId) {
  if ($.inArray(divId, shownArray) == -1) {
    googletag.cmd.push(() => {
      shownArray.push(divId);
      googletag.display(divId);
    });
  } else {
    const lastRefreshedTime = slotTimers[divId];
    if (
      lastRefreshedTime === undefined ||
      new Date().getTime() - lastRefreshedTime >= 1000
    ) {
      slotTimers[divId] = new Date().getTime();
      googletag.pubads().refresh([slots[divId]]);
    }
  }
};

const showAdByName = function(name, slotOccurrenceNumber = 1) {
  showAd(slotIdFromName(name, slotOccurrenceNumber));
};

const destroyAdByName = function(name, slotOccurrenceNumber = 1) {
  destroyAd(slotIdFromName(name, slotOccurrenceNumber));
};

const wrapFunction = function(fn, context, params) {
  return function() {
    fn.apply(context, params);
  };
};

const addToAdSlotDefinitionArray = function(fn, context, params) {
  functionSlotDefinitionArray.push(wrapFunction(fn, context, params));
};

const addToAdShowArray = function(fn, context, params) {
  functionAdShowArray.push(wrapFunction(fn, context, params));
};

const checkMessageOrigin = function(origin) {
  return (
    typeof origin === 'string' &&
    (origin.match(/greatschools\.org$/) ||
      origin.match(/googlesyndication\.com$/) ||
      origin.match(/doubleclick\.net$/))
  );
};

const handleGhostTextMessages = function(event) {
  if (
    typeof event !== 'undefined' &&
    checkMessageOrigin(event.origin) &&
    typeof event.data !== 'undefined' &&
    typeof event.data.ghostText === 'string'
  ) {
    jQuery('iframe').each(function() {
      if (
        this.getAttribute('name') &&
        window.frames[this.getAttribute('name')] == event.source
      ) {
        const $adSlotDiv = jQuery(this).parents('.gs_ad_slot');
        const slotName = $adSlotDiv.attr('id');
        let $adTextDiv = $adSlotDiv
            .parents(`.js-${slotName}-wrapper`)
            .find('.advertisement-text');
        if ($adTextDiv.length === 0) {
          // Probably under /gk/
          $adTextDiv = $adSlotDiv.find('.advertisement-text');
        }
        $adTextDiv.text(event.data.ghostText);
      }
    });
  }
};

const addCompfilterToGlobalAdTargetingGon = function() {
  const randomCompFilterValue = (Math.floor(Math.random() * 4) + 1).toString();
  if (!gon.ad_set_targeting) {
    gon.ad_set_targeting = {};
  }
  gon.ad_set_targeting.compfilter = randomCompFilterValue;
};

window.addEventListener('message', handleGhostTextMessages, false);

// /// examples
// desktop
// <div class="gs_ad_slot visible-lg visible-md" id="div-gpt-ad-1397603538853-0" data-ad-size="[[300,600],[300,250]]" style="width: 300px;" data-dfp="School_Overview_Snapshot_300x250"></div>

// mobile
// <div class="gs_ad_slot visible-sm visible-xs" id="div-gpt-ad-1397602726713-0" data-ad-size="[300,250]" style="width: 300px;" data-dfp="School_Overview_Mobile_Snapshot_300x250"></div>

function enableAdCloseButtons() {
  $('.js-closable-ad').on('click', '.close', function(element) {
    $(this)
      .closest('.js-closable-ad')
      .remove();
  });
}

function checkSponsorSearchResult() {
  setTimeout(()=>{
    const searchResult = document.querySelector('.sponsored-school-result-ad')
    let adLoaded = true;
    if (searchResult){
      searchResult.querySelectorAll('div').forEach(node => {
        if (node.classList.contains('dn')){
          adLoaded = false;
        }
      })
      if (adLoaded){
        searchResult.classList.remove('dn');
      }
    }
  }, 2000)
}

// function to add targeted styles to an ad. Will attempt for ten seconds, otherwise it will cease running
// adClass is a STRING with the ad class you are targeting
// dimension is an array of the dimensions you are targeting e.g. [WIDTH, HEIGHT]
// styling is an string of key-values pairs delimited by `;`
const applyStylingToIFrameAd = (adClass, dimension, styling, counter = 0 ) => {
  if (window.innerWidth < 1200 || counter > 10){ return null;}
  const adElement = document.querySelector(adClass)
  const adElementIframe = adElement.querySelector('iframe');

  if (adElement && adElementIframe) {
    if (adElementIframe.dataset.loadComplete === "true") {
      const width = String(dimension[0])
      const height = String(dimension[1])
      if (adElementIframe.width === width && adElementIframe.height === height) {
        adElement.style.cssText = styling;
      } else {
        return null;
      }

    } else {
      setTimeout(()=>applyStylingToIFrameAd(adClass, dimension, styling, counter++), 1000)
    }
  } else {
    setTimeout(()=>applyStylingToIFrameAd(adClass, dimension, styling, counter++), 1000)
  }
}

GS.ad.addCompfilterToGlobalAdTargetingGon = addCompfilterToGlobalAdTargetingGon;
GS.ad.showAd = showAd;
GS.ad.slotRenderedHandler = slotRenderedHandler;
GS.ad.init = init;
export {
  init,
  onInitialize,
  showAd,
  showAdByName,
  enableAdCloseButtons,
  defineAdOnce,
  destroyAd,
  destroyAdByName,
  slotIdFromName,
  checkSponsorSearchResult,
  applyStylingToIFrameAd
};
