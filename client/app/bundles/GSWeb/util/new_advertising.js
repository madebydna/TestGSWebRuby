const $ = window.jQuery;
const advertising_enabled = gon.advertising_enabled;

import {
  onAdFilled as onMobileOverlayAdFilled,
  onAdNotFilled as onMobileOverlayAdNotFilled
} from 'components/ads/mobile_overlay';

window.freestar = window.freestar || {};
freestar.hitTime = Date.now();
freestar.queue = freestar.queue || [];
freestar.config = freestar.config || {};
freestar.debug = window.location.search.indexOf('fsdebug') === -1 ? false : true;
freestar.config.enabled_slots = [];
if (gon.advertising_enabled) {
  !function(a,b){
    var c=b.getElementsByTagName("script")[0]
    var d=b.createElement("script")
    var e="https://a.pub.network/greatschools-org";
    e+=freestar.debug?"/qa/pubfig.min.js":"/pubfig.min.js",
    d.async=!0
    d.src=e
    c.parentNode.insertBefore(d,c)
  }(window,document);
}
freestar.initCallback = () => {
  (freestar.config.enabled_slots.length === 0) ? freestar.initCallbackCalled = false : freestar.newAdSlots(freestar.config.enabled_slots);
}

window.GS = window.GS || {};
GS.ad = GS.ad || {};
GS.ad.slot = GS.ad.slot || {};
const slotCallbacks = GS.ad.slot;
const slotTimers = {};

let initialized = false;
const onInitializeFuncs = [];

const MAX_COUNTER = 10;
const DELAY_IN_MS = 1000;

const init = function() {
  if (advertising_enabled) {
    _setPageLevelTargeting();

    const dfp_slots = $('.gs_ad_slot').filter(':visible,[data-ad-defer-render]');
    $(dfp_slots).each(function() {
      _defineSlot($(this));
    });
    console.log("Num enabled slots", freestar.config.enabled_slots.length);

    // custom initialization functions
    while (onInitializeFuncs.length > 0) {
      onInitializeFuncs.shift()();
    }

    console.log('NEW AD ... enabled slots after custom init functions', freestar.config.enabled_slots.length);
    checkForFreeStarLoaded(postFreestarLoaded);
  }
}

const checkForFreeStarLoaded = (callback) => {
  if (!freestarLoaded()) {
    console.log('!--- freestar not yet loaded');
    // check for loaded with the interval of 0.5 seconds
    const checkLoaded = setInterval(() => {
      console.log('+-- checking for freestar loaded', freestarLoaded());
      if (freestarLoaded()) {
        callback();
        clearInterval(checkLoaded);
      };
    }, 500);
    // after 5 seconds stop
    setTimeout(() => { clearInterval(checkLoaded); }, 5000);
  } else {
    console.log('!--- freestar already loaded');
    callback();
  }
}

const postFreestarLoaded = () => {
  // freestar.initCallback();

  // loop through slots and call callback
  $.each(freestar.config.enabled_slots, (_, slot) => {
    console.log('NEW AD ... showing', slot.placementName, 'for the first time');
    if (slotCallbacks[slot.placementName]) slotCallbacks[slot.placementName]();
    slotTimers[slot.placementName] = new Date().getTime();
  });

  initialized = true;
}

const freestarLoaded = () =>
  typeof(freestar.newAdSlots) === typeof(Function)

const onInitialize = func =>
  initialized ? func() : onInitializeFuncs.push(func);


const slotRenderedHandler = function(slot, slotId) {
  return function() {
    // this assumes ad was actually rendered
    console.log("SlotRenderedHandler for slot", slot, " was called");
    const $wrapper = $(`.js-${slotId}-wrapper`);
    if ($wrapper.hasClass('mobile-ad-sticky-bottom')) {
      onMobileOverlayAdFilled();
    }
    if ($wrapper.hasClass('dn')) {
      $wrapper.removeClass('dn');
    }
    // Show the ghost text as an ad is rendered
    const $ghostText = $(`.js-${slotId}-ghostText`); // wordpress
    if ($ghostText.length > 0) {
      $ghostText.appendTo($ghostText.parent());
      $ghostText.show();
    }
    $(`.js-${slotId}-wrapper .advertisement-text`)
      .removeClass('dn')
      .show();
  }
}

const _defineSlot = function($adSlot) {
  let deferRender = $adSlot.data('ad-defer-render') !== undefined
  if (deferRender) return;
  freestar.config.enabled_slots.push({ placementName: $adSlot.data('dfp'), slotId: $adSlot.attr('id') });
  slotCallbacks[$adSlot.data('dfp')] = slotRenderedHandler($adSlot.data('dfp'), $adSlot.attr('id'));
};

const defineAdOnce = function(slot, slotOccurrenceNumber, onRenderEnded) {
  console.log("Defining slot", slot, "initially");
  freestar.config.enabled_slots.push({ placementName: slot, slotId: slotIdFromName(slot, slotOccurrenceNumber) });
  slotCallbacks[slot] = onRenderEnded;
};

const adsInitialized = function() {
  return initialized;
}

const _setPageLevelTargeting = function() {
  // being set in localized_profile_controller - ad_setTargeting_through_gon
  // sets all targeting based on what is set in the controller
  if ($.isEmptyObject(gon.ad_set_targeting)) {
    if ($.isEmptyObject(GS.ad.adSetTargeting)) {
      console.log('gon setTargeting and GS.ad.adSetTargeting are empty for advertising');
    } else {
      // This is for WordPress which uses GS.ad.adSetTargeting (not having access to gon)
      $.each(GS.ad.adSetTargeting, (key, value) => {
        freestar.queue.push(function() {
          googletag.pubads().setTargeting(key, value);
        });
      });
    }
  } else {
    $.each(gon.ad_set_targeting, (key, value) => {
      freestar.queue.push(function() {
        googletag.pubads().setTargeting(key, value);
      });
    });
  }
};

const slotIdFromName = (slot, slotOccurrenceNumber = 1) => {
  return `${slot}_${slotOccurrenceNumber}`;
};

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

const showAd = function(slot, slotOccurrenceNumber, onRenderEnded = null) {
  const lastRefreshedTime = slotTimers[slot];
  console.log("NEW AD ... last refreshed time", slot, lastRefreshedTime);
  if (
    lastRefreshedTime === undefined ||
    new Date().getTime() - lastRefreshedTime >= 1000
  ) {
    let divId = slotIdFromName(slot, slotOccurrenceNumber);
    console.log("NEW AD ... refreshing ad", slot, divId);
    slotTimers[slot] = new Date().getTime();
    freestar.newAdSlots([{
      placementName: slot,
      slotId: divId
    }]);
    if (onRenderEnded) onRenderEnded();
  } else {
    console.log("NEW AD ... NOT refreshing not enough time passed", slot);
  }
};

const destroyAd = (slot) => {
  console.log("NEW AD ... destroying ad", slot);
  freestar.deleteAdSlots(slot);
};

// function to add targeted styles to an ad. Will attempt for ten seconds, otherwise it will cease running
// selector is a STRING with sthe selector you are using to target
// dimension is an array of the dimensions you are targeting e.g. [WIDTH, HEIGHT]
// styling is an string of key-values pairs delimited by `;`
const applyStylingToIFrameAd = (selector, dimension, styling, counter = 0 ) => {
  if (window.innerWidth < 1200 || counter > MAX_COUNTER){ return; }
  const adElement = document.querySelector(selector);
  let adElementIframe;
  if (adElement) {
    adElementIframe = adElement.querySelector('iframe');
  }

  if (adElement && adElementIframe) {
    if (adElementIframe.dataset.loadComplete === "true") {
      const width = String(dimension[0]);
      const height = String(dimension[1]);
      if (adElementIframe.width === width && adElementIframe.height === height) {
        adElement.style.cssText = styling;
        return;
        }
      }
    }

  setTimeout(() => applyStylingToIFrameAd(selector, dimension, styling, counter++), DELAY_IN_MS)
}

function enableAdCloseButtons() {
  $('.js-closable-ad').on('click', '.close', function(element) {
    $(this)
      .closest('.js-closable-ad')
      .remove();
  });
}

const addCompfilterToGlobalAdTargetingGon = function() {
  const randomCompFilterValue = (Math.floor(Math.random() * 4) + 1).toString();
  if (!gon.ad_set_targeting) {
    gon.ad_set_targeting = {};
  }
  gon.ad_set_targeting.compfilter = randomCompFilterValue;
};

GS.ad.addCompfilterToGlobalAdTargetingGon = addCompfilterToGlobalAdTargetingGon;
GS.ad.showAd = showAd;
GS.ad.init = init; // used by WP, for instance

export {
  init,
  onInitialize,
  destroyAd,
  slotIdFromName,
  defineAdOnce,
  enableAdCloseButtons,
  showAd,
  checkSponsorSearchResult,
  adsInitialized,
  applyStylingToIFrameAd,
  checkForFreeStarLoaded
};