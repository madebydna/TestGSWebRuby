import { scrollToElement } from '../util/scrolling';

let overlaySelector = '.overlay';
let stickyHighlightClass = 'sticky-highlight';

function makeSticky(selector) {
  $(overlaySelector).show();
  $('body').css('overflow', 'hidden');
  $(selector).css('width', $(selector).width());
  $(selector).addClass(stickyHighlightClass);
}

function restore(selector) {
  $(overlaySelector).hide();
  $('body').css('overflow', 'auto');
  $(selector).removeClass(stickyHighlightClass);
  scrollToElement(selector);
}

export function stickyHighlight(selector) {
  scrollToElement(selector);
  makeSticky(selector);
  $('body').on('click.sticky-highlight', selector + ', ' + overlaySelector, function() {
    $(selector).off('click.sticky-highlight');
    $(overlaySelector).off('click.sticky-highlight');
    restore(selector);
    scrollToElement(selector);
  });
}

