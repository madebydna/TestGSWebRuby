import {
  renderAd as renderMobileOverlayAd,
  setDeferred as setMobileOverlayAdDeferred
} from 'components/ads/mobile_overlay';
import log from 'util/log';

window.GS_interruptManager_interrupts = window.GS_interruptManager_interrupts || {};

export function mobileOverlayAd(nextInterrupt) {
  log('mobile overlay interrupt');
  setMobileOverlayAdDeferred($.Deferred().fail(function() {
    log('mobile overlay interrupt passed');
    nextInterrupt();
  }));
  renderMobileOverlayAd(); 
}

export function qualaroo(nextInterrupt) {
  log('qualaroo interrupt');
  GS_initQualaroo();
}

const interrupts = {
  mobileOverlayAd: mobileOverlayAd,
  qualaroo: qualaroo
}

export function registerPredefinedInterrupts(array) {
  array.forEach((name) => {
    GS_interruptManager_interrupts[name] = interrupts[name];
  })
}

export function registerInterrupt(name, callback) {
  GS_interruptManager_interrupts[name] = callback;
}

export function runInterrupts(array) {
  if(window.GS_interruptManager) {
    GS_interruptManager.runInterrupts(array);
  }
}
