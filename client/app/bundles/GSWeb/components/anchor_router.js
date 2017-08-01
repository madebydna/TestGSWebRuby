import { scrollToElement } from '../util/scrolling';
let autoAnchoring = false;
let haveAutoScrolled = false;
let anchorMap;
let autoAnchorAttemptIntervalId;

function anchorTokens() {
  let tokens = document.location.hash.slice(1).split('|');
  return tokens;
}

export function enableAutoAnchoring(map) {
  autoAnchoring = true;
  anchorMap = map;
  autoAnchorAttemptIntervalId = window.setInterval(attemptAutoAnchor, 100);
}

function highlightForAMoment(selector) {
  let backgroundColor = $(selector).css('background-color');
  $(selector).css('background-color', '#ffff93', 'important');
  setTimeout(() => $(selector).css('background-color', '', ''), 750);
}

function scrollAndHighlight(selector) {
  haveAutoScrolled = true;
  if ('scrollRestoration' in window.history) {
    window.history.scrollRestoration = 'manual';
  }
  scrollToElement(selector, () => {
    highlightForAMoment(selector);
    window.clearInterval(autoAnchorAttemptIntervalId);
  });
}

export function scrollToAnchor() {
  let firstToken = anchorTokens()[0];
  let selector = anchorMap[firstToken];
  if(selector && $(selector).length > 0) {
    scrollAndHighlight(selector);
  }
}

function attemptAutoAnchor() {
  if(!haveAutoScrolled) {
    scrollToAnchor();
  }
}

//////////////////////////////////////////////////////////////////////////////

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
