GS.viewMoreCollapseInit = function(options) {
  var toggleSelector = '.js-view-more';

  $(toggleSelector).each(function() {
    var $p = $(this);
    var $content = $(this).siblings('div');
    $content.hide();

    $p.click(function() {
      $content.slideToggle({
        complete: function() {
          if ($content.css('display') === "block") {
            $p.text('View Less »');
          } else if ($content.css('display') === "none") {
            $p.text('View More »');
          }
        }
      });
    });
  });
}
