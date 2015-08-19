$(function() {
  if (gon.pagename == GS.CommunityScorecards.Page.pageName) {
    GS.CommunityScorecards.Page.init();

    $('.js-communityScorecard').on('click', '.js-tableSort', function (e) {
      $('.js-tableSort').addClass('sort-link');
      $(this).removeClass('sort-link');
    });
  }
});
