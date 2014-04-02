GS.viewMoreCollapseInit = function() {
  var textSelector = '.js-module-expand';
  var foldHeight = 71;

  function heightSwitch($p) {
    var oldHeight = $p.css('height');
    $p.css('height', 'auto');
    var fullHeight = $p.css('height');
    $p.css('height', oldHeight);
    $p.data('height', fullHeight);
  }

  function expandClick() {
    $(this).text('View Less');
    var $p = $(this).parent().find(textSelector);
    var originalHeight = $p.data('height');
    $p.animate({ height: originalHeight });
    $(this).unbind('click')
    $(this).click(collapseClick)
  }

  function collapseClick() {
    $(this).text('View More »')
    var $p = $(this).parent().find(textSelector);
    heightSwitch($p)
    $p.animate({ height: foldHeight + 'px' })
    $(this).unbind('click')
    $(this).click(expandClick)
  }

  $('p.view-more').each(function() {
    var $p = $(this).parent().find(textSelector);
    heightSwitch($p)
    $(this).click(expandClick)
  })
}

$(document).ready(function() {
  GS.viewMoreCollapseInit();
})
