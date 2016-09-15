$(function() {
  $('.js-shortened-text').each(function() {
    var $text = $(this);
    var extraText = $text.data('shortened-text-rest');
    $text.find('span').on('click', function() {
      $(this).hide();
      $text.html($text.html() + extraText);
    });
  });
})();
