GS.viewMoreCollapseInit = function(options) {
  var textSelector = '.js-module-expand';
  var toggleSelector = 'p.view-more';
  var foldHeight = options['foldHeight'] || 71;
  var lineHeight = 20;

  function heightSwitch($p) {
    var oldHeight = $p.css('height');
    $p.css('height', 'auto');
    var fullHeight = $p.css('height');
    $p.css('height', oldHeight);
    $p.data('height', fullHeight);

    return parseInt(fullHeight) - foldHeight;
  }

  function expandClick() {
    var $this = $(this)
    $this.text('View Less');
    var $p = $this.parent().find(textSelector);
    var fullHeight = $p.data('height');
    $p.stop().animate({
      height: fullHeight
    }, 'linear');
    $this.unbind('click');
    $this.click(collapseClick);
  }

  function collapseClick() {
    var $this = $(this);
    $this.text('View More »');
    var $p = $this.parent().find(textSelector);
    $p.stop().animate({ height: foldHeight + 'px' }, 'linear');
    $this.unbind('click');
    $this.click(expandClick);
  }

  function initExpandCollapse() {
    $(toggleSelector).each(function() {
      var $this = $(this);
      var $p = $this.parent().find(textSelector);
      var heightDiff = heightSwitch($p);

      if ($this.text() == 'View Less') {
        if (heightDiff > lineHeight) {
          $p.css('height', 'auto');
          $this.show()
               .unbind('click')
               .click(collapseClick);
        } else {
          $p.css('height', $p.data('height'));
          $this.hide();
        }
      } else {
        if (heightDiff > lineHeight) {
          $this.show()
               .click(expandClick);
        } else {
          $this.hide();
        }
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
