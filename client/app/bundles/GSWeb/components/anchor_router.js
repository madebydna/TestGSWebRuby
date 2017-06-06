import { scrollToElement } from '../util/scrolling';
import { stickyHighlight } from './sticky_highlight';

let anchor = document.location.hash;

let anchorMap = {
  'Low-income_students': '#EquityLowIncome'
};

function anchorTokens() {
  let tokens = anchor.slice(1).split('|');
  return tokens;
}

export function handleAnchor(token, callback) {
  let tokens = anchorTokens();
  if(tokens[0] == token) {
    callback(tokens.slice(1));
  }
}

let haveAutoScrolled = false;
export function autoAnchor() {
  let firstToken = anchorTokens()[0];
  let selector = anchorMap[firstToken];
  if(!haveAutoScrolled && selector && $(selector).length > 0) {
    if ('scrollRestoration' in window.history) {
      window.history.scrollRestoration = 'manual';
    }
    haveAutoScrolled = true;
    scrollToElement(selector);
    stickyHighlight(selector);
  } else {
    window.setTimeout(autoAnchor, 100);
  }
}
