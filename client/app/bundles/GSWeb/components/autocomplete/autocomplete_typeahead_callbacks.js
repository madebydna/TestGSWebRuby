//Hooks into the Autocomplete library for various events
//EX. onUpKeyedCallback will execute when the users key is finished clicking
let onUpKeyedCallback = null;
let onDownKeyedCallback = null;
let onQueryChangedCallback = null;

const setOnUpKeyedCallback = function(callback) {
  onUpKeyedCallback = callback;
};

const setOnDownKeyedCallback = function(callback) {
  onDownKeyedCallback = callback;
};

const setOnQueryChangedCallback = function(callback) {
  onQueryChangedCallback = callback;
};

const getOnUpKeyedCallback = function() {
  return onUpKeyedCallback;
};

const getOnDownKeyedCallback = function() {
  return onDownKeyedCallback;
};

const getOnQueryChangedCallback = function() {
  return onQueryChangedCallback;
};



export {
  setOnUpKeyedCallback,
  setOnQueryChangedCallback,
  setOnDownKeyedCallback,
  getOnUpKeyedCallback,
  getOnQueryChangedCallback,
  getOnDownKeyedCallback
}
