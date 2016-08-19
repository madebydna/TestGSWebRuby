$(function () {
  if (gon.pagename == 'GS:State:Enrollment') {
    GS.viewMoreCollapseInit({'foldHeight': 292});
    GS.customCarouselControl.cycle2Carousel.enableMultipleCarouselsNav();
  } else if (gon.pagename == 'GS:City:Enrollment') {
    GS.viewMoreCollapseInit({'foldHeight': 292});
  }
});