GS.viewMoreCollapseInit = function(options) {
  var textSelector = '.js-module-expand';
  var toggleSelector = '.view-more';

  $(toggleSelector).each(function() {
    var $p = $(this);
    var $content = $(this).siblings(textSelector);
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
