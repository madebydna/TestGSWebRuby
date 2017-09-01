import { scrollToElement } from '../util/scrolling';
let autoAnchoring = false;
let haveScrolled = false;
let anchorMap;
let autoAnchorAttemptIntervalId;

const HASH_SEPARATOR = "*";

export function initAnchorHashUpdater() {
  $('body').on('click', '.js-updateLocationHash', function () {
    changeLocationHash($(this).attr('data-anchor'));
  });
}

function changeLocationHash(hashToSet) {
  history.replaceState(undefined, undefined, "#"+hashToSet);
}

function anchorTokens() {
  let tokens = document.location.hash.slice(1).split(HASH_SEPARATOR);
  return tokens;
}

export function enableAutoAnchoring(map) {
  addAnchorChangeCallback(scrollToAnchor);
  addAnchorChangeCallback(disableAutoAnchoring);
  autoAnchoring = true;
  anchorMap = map;
  autoAnchorAttemptIntervalId = window.setInterval(attemptAutoAnchor, 100);
}

function disableAutoAnchoring() {
  autoAnchoring = false;
  window.clearInterval(autoAnchorAttemptIntervalId);
}

function highlightForAMoment(selector) {
  let backgroundColor = $(selector).css('background-color');
  $(selector).css('background-color', '#cbe2ec', 'important');
  setTimeout(() => $(selector).css('background-color', '', ''), 750);
}

function scrollAndHighlight(selector) {
  haveScrolled = true;
  if ('scrollRestoration' in window.history) {
    window.history.scrollRestoration = 'manual';
  }
  scrollToElement(selector, () => highlightForAMoment(selector));
}

function scrollWithoutHighlight(selector) {
  haveScrolled = true;
  if ('scrollRestoration' in window.history) {
    window.history.scrollRestoration = 'manual';
  }
  scrollToElement(selector);
}

export function scrollToAnchor() {
  disableAutoAnchoring();
  let firstToken = anchorTokens()[0];
  let selector = anchorMap[firstToken];
  if(selector && $(selector).length > 0) {
    scrollWithoutHighlight(selector);
  }
}

function scrollToAnchorAndHighlight() {
  disableAutoAnchoring();
  let firstToken = anchorTokens()[0];
  let selector = anchorMap[firstToken];
  if(selector && $(selector).length > 0) {
    scrollAndHighlight(selector);
  }
}

function attemptAutoAnchor() {
  if(!haveScrolled) {
    scrollToAnchorAndHighlight();
  }
}

//////////////////////////////////////////////////////////////////////////////

export function formatAnchorString(str) {
  if(typeof str === 'undefined' || str == '' || str === null) return '';
  return str.split(' ').join('_').replace('/', '_');
}

export function hashSeparatorAnchor() {
  return HASH_SEPARATOR;
}

export function addAnchorChangeCallback(callback) {
  window.addEventListener('hashchange', callback, false);
}

export function removeAnchorChangeCallback(callback) {
  window.removeEventListener('hashchange', callback, false);
}

export function handleAnchor(token, callback) {
  let tokens = anchorTokens();
  if(tokens[0] == token) {
    callback(tokens.slice(1));
  }
}

export function handleThirdAnchor(token, callback) {
  let tokens = anchorTokens();
  if(tokens[1] == token) {
    callback(tokens.slice(2));
  }
}
