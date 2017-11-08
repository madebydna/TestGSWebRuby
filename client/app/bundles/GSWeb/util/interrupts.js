import {
  renderAd as renderMobileOverlayAd,
  setDeferred as setMobileOverlayAdDeferred
} from 'components/ads/mobile_overlay';
import log from 'util/log';

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
  if(window.GS_interruptManager) {
    array.forEach((name) => {
      GS_interruptManager.registerInterrupt(name, interrupts[name]);
    })
  }
}

export function registerInterrupt(...args) {
  if(window.GS_interruptManager) {
    GS_interruptManager.registerInterrupt(...args);
  }
}

export function runInterrupts(array) {
  if(window.GS_interruptManager) {
    GS_interruptManager.runInterrupts(array);
  }
}
