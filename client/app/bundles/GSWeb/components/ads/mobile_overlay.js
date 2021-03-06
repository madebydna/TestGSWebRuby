import { showAd, enableAdCloseButtons } from 'util/advertising';
import { onScroll } from 'util/scrolling';

const adDomId = 'Mobile_overlay_Ad';
const containerSelector = '.mobile-ad-sticky-bottom';
let deferred;
let $ = window.jQuery;

export function renderAd() {
  /*
   * The ad container must be completely hidden on all screen sizes
   * prior to knowing if it will show and before asking ad server to fill it.
   * But the container needs to be visible (yet still offscreen) when
   * we ask the ad server to fill.
   */
  $(containerSelector).css('display', 'block');
  enableAdCloseButtons();
  if($('#' + adDomId).is(":visible")) {
    showAd(adDomId);
  } else {
    onAdNotFilled();
  }
}

let mobileOverlayShown = false

export function renderAdOnScrollHalfway() {
  onScroll('mobileOverlay', ({ ratioScrolledDown } = {}) => {
    if(mobileOverlayShown) {
      return false;
    }
    if(ratioScrolledDown > .5) {
      mobileOverlayShown = true;
      renderAd()
    }
  })
}

window.GS_renderMobileOverlayAd = renderAd; // TODO: remove after other pages use webpack
window.GS_renderMobileOverlayAdOnScroll = renderAdOnScrollHalfway; // TODO: remove after other pages use webpack

export function revealContainer() {
  $(containerSelector).css('position', 'fixed');
  $(containerSelector).animate({bottom: "0px"}, 500);
}

export function startAutoCloseTimer(duration = 1000 * 30) {
  setTimeout(function() {
    $(containerSelector).remove();
  }, duration);
}

export function onAdFilled() {
  setTimeout(function() {
    revealContainer();
    startAutoCloseTimer();
    if(deferred) {
      deferred.resolve();
    }
  }, 1000 * 2);
}
window.GS_onMobileOverlayAdFilled = onAdFilled;

export function onAdNotFilled() {
  if(deferred) {
    deferred.reject();
  }
}
window.GS_onMobileOverlayAdNotFilled = onAdNotFilled;

export function setDeferred(_deferred) {
  deferred = _deferred;
}
