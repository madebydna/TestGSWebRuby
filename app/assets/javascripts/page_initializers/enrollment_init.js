$(function () {
  if (gon.pagename == 'GS:State:Enrollment') {
    GS.customCarouselControl.cycle2Carousel.enableMultipleCarouselsNav();
  }
  if ((gon.pagename.indexOf("GS:City:Enrollment") >= 0) || (gon.pagename.indexOf("GS:State:Enrollment") >= 0)){
    GS.viewMoreCollapseInit({'foldHeight': 292});
  }
});