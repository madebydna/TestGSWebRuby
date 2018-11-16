import { throttle, debounce } from 'lodash';
import { ratioScrolledDown } from 'util/viewport';

export const scrollHandlers = [];

export const onScroll = (callback) => {
  scrollHandlers.push(callback)
}

let handleScroll = () => {
  scrollHandlers.forEach((handler) => {
    handler({
      ratioScrolledDown: ratioScrolledDown()
    });
  });
}
handleScroll = throttle(handleScroll, 40);

window.addEventListener('scroll', handleScroll)

export function scrollToElement(selector, doneCallback, additionalYOffset=0) {
  if($(selector).length > 0) {
    let y = $(selector).offset().top + additionalYOffset;
    let widthWithSearchBar = 767;
    let searchBarHeight = 48;

    let fixedTopSelector = $('.js-profile-sticky,.js-profile-sticky-mobile,.menu_layout_mobile:visible');
    var offset = Math.max(...$(fixedTopSelector).map((i, el) => $(el).height()));

    if($('.js-profile-sticky:visible').length > 0) {
      offset += 135;
    } else if($('.js-profile-sticky-mobile:visible').length > 0) {
      offset += 120;
    }
    
    $('html,body').animate({scrollTop:y - offset}, 500, 'swing', doneCallback);
  }
}
