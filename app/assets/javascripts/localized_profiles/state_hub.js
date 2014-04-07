GS.viewMoreCollapseInit = function() {
  var textSelector = '.js-module-expand';
  var foldHeight = 71;

  function heightSwitch($p) {
    var oldHeight = $p.css('height');
    $p.css('height', 'auto');
    var fullHeight = $p.css('height');
    $p.css('height', oldHeight);
    $p.data('height', fullHeight);
    return parseInt(fullHeight) - parseInt(oldHeight);
  }

  function expandClick() {
    $(this).text('View Less');
    var $p = $(this).parent().find(textSelector);
    var fullHeight = $p.data('height');
    $p.animate({ height: fullHeight });
    $(this).unbind('click')
    $(this).click(collapseClick)
  }

  function collapseClick() {
    $(this).text('View More »')
    var $p = $(this).parent().find(textSelector);
    $p.animate({ height: foldHeight + 'px' })
    $(this).unbind('click');
    $(this).click(expandClick);
  }

  function initExpandCollapse() {
    $('p.view-more').each(function() {
      var $p = $(this).parent().find(textSelector);
      $p.show();
      var heightDiff = heightSwitch($p);
      if (heightDiff > 20) {
        $(this).click(expandClick);
      } else {
        $(this).hide();
      }
    });
  }

  var reinitTimer;
  $(window).resize(function() {
      clearTimeout(reinitTimer);
      reinitTimer = setTimeout(initExpandCollapse, 100);
  });
  initExpandCollapse();
}

$(document).ready(function() {
  GS.viewMoreCollapseInit();
})
