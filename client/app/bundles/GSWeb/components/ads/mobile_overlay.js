import { showAd, enableAdCloseButtons } from 'util/advertising';

const adDomId = 'Mobile_overlay_Ad';
const containerSelector = '.mobile-ad-sticky-bottom';

export function renderAd() {
  enableAdCloseButtons();
  if($('#' + adDomId).is(":visible")) {
    showAd(adDomId);
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
