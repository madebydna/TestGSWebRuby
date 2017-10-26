export function scrollToElement(selector, doneCallback) {
  console.log("selector: "+selector);
  if($(selector).length > 0) {
    let y = $(selector).offset().top;
    let widthWithSearchBar = 767;
    let searchBarHeight = 48;
    console.log("document.documentElement.clientWidth: "+document.documentElement.clientWidth);
    console.log("y: "+y);
    console.log("searchBarHeight: "+searchBarHeight);
    if(document.documentElement.clientWidth <= widthWithSearchBar) {
      // html needed in selector because firefox overflows at html node
      $('html,body').animate({scrollTop:y-searchBarHeight}, 500, 'swing', doneCallback);
    } else {
      $('html,body').animate({scrollTop:y}, 500, 'swing', doneCallback);
    }
  }
}
