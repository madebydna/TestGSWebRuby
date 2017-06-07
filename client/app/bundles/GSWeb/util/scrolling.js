export function scrollToElement(selector, doneCallback) {
  if($(selector).length > 0) {
    let y = $(selector).offset().top;
    let widthWithSearchBar = 767;
    let searchBarHeight = 48;
    if(document.documentElement.clientWidth <= widthWithSearchBar) {
      $('body').animate({scrollTop:y-searchBarHeight}, 500, 'swing', doneCallback);
    } else {
      $('body').animate({scrollTop:y}, 500, 'swing', doneCallback);
    }
  }
}
