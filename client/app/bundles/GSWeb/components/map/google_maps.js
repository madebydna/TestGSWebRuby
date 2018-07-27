import { getScript } from '../../util/dependency';

const scriptURL =
  '//maps.googleapis.com/maps/api/js?key=AIzaSyA2A9es1i_iP9joGhiV9Yhez1WjVoV37l4&libraries=places,geometry';
const callbackFunctions = [];

function executeCallbacks() {
  while (callbackFunctions.length > 0) {
    callbackFunctions.shift().call();
  }
}

function makeCallbackFunctionGlobal() {
  window.GS = window.GS || {};
  window.GS._google_maps_init_callback = executeCallbacks;
}

function isInitialized() {
  return window.googleMapsInitialized === true;
}

export function addInitCallback(func) {
  if (func) {
    callbackFunctions.push(func);
  }
}

addInitCallback(() => {
  window.googleMapsInitialized = true;
});

export function init(func) {
  if (isInitialized()) {
    func();
    return;
  }
  addInitCallback(func);
  makeCallbackFunctionGlobal();
  getScript(`${scriptURL}&callback=window.GS._google_maps_init_callback`);
}
