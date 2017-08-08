import { getScript } from '../../util/dependency';

const scriptURL = '//maps.googleapis.com/maps/api/js?client=gme-greatschoolsinc&amp;libraries=geometry&amp;sensor=false&amp;signature=qeUgzsyTsk0gcv93MnxnJ_0SGTw=';
const callbackFunctions = [];

function callbackFunction() {
  for(let i = 0; i < callbackFunctions.length; i++) {
    callbackFunctions[i].call();
  }
}

function makeCallbackFunctionGlobal() {
  window.GS = window.GS || {};
  window.GS._google_maps_init_callback = function() {
    callbackFunction();
  }
}

export function addInitCallback(func) {
  if(func) {
    callbackFunctions.push(func);
  }
}

export function init(func) {
  addInitCallback(func);
  makeCallbackFunctionGlobal();
  getScript(scriptURL + '&callback=window.GS._google_maps_init_callback');
};

