import { scrollToElement } from '../util/scrolling';
let anchor = document.location.hash;

let autoAnchoring = false;
let haveAutoScrolled = false;
let anchorMap;
let autoAnchorAttemptIntervalId;

function anchorTokens() {
  let tokens = anchor.slice(1).split('|');
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

function autoAnchor(selector) {
  haveAutoScrolled = true;
  if ('scrollRestoration' in window.history) {
    window.history.scrollRestoration = 'manual';
  }
  scrollToElement(selector, () => {
    highlightForAMoment(selector);
    window.clearInterval(autoAnchorAttemptIntervalId);
  });
}

function attemptAutoAnchor() {
  let firstToken = anchorTokens()[0];
  let selector = anchorMap[firstToken];

  if(!haveAutoScrolled && selector && $(selector).length > 0) {
    autoAnchor(selector);
  }
}

//////////////////////////////////////////////////////////////////////////////

export function handleAnchor(token, callback) {
  let tokens = anchorTokens();
  if(tokens[0] == token) {
    callback(tokens.slice(1));
  }
}
