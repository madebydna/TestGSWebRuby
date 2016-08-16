var GS = GS || {};
GS.showMore = GS.showMore || function(){
  var selector = '.show-more';
  var filterSelector = '.show-more__button';
  var targetSelector = '.show-more__items';

  $(selector).on('click', filterSelector, function() {
    var $this = $(this);
    var $container = $this.closest(selector);
    var $target = $container.find(targetSelector);
    $container.toggleClass('show-more--closed');
    $container.toggleClass('show-more--open');
    if ($this.text().toLowerCase().indexOf('more') > -1) {
      $target.show();
      $container = $this.closest(selector);
      $this.html('Show Less');
    } else {
      $target.hide();
      $this.html('Show More');
    }
  });
};
$(function() {
  GS.showMore();
});
