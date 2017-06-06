export function scrollToElement(selector) {
  if($(selector).length > 0) {
    let top = $(selector).offset().top;
    setTimeout(function() {
      $(function() {
        $(window).scrollTop(top);
      });
    }, 1);
  }
}
