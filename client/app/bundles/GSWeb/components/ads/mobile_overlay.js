import { showAd, enableAdCloseButtons } from 'util/advertising';

const adDomId = 'Mobile_overlay_Ad';
const containerSelector = '.mobile-ad-sticky-bottom';
let deferred;

export function renderAd() {
  enableAdCloseButtons();
  if($('#' + adDomId).is(":visible")) {
    showAd(adDomId);
  } else {
    onAdNotFilled();
  }
}

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
  }, 1000 * 5);
}

export function onAdNotFilled() {
  if(deferred) {
    deferred.reject();
  }
}

export function setDeferred(_deferred) {
  deferred = _deferred;
}
