var GS = GS || {};
GS.syncHeight = GS.syncHeight || (function() {
  var syncHeights = function() {
    var $elements = $('.js-syncHeight');
    var maxHeight = -1;
    $elements.each(function() {
      maxHeight = maxHeight > $(this).height() ? maxHeight : $(this).height();
    });
    $elements.each(function() {
      $(this).height(maxHeight);
    });
  };
  return {
    syncHeights: syncHeights
  };
})();
