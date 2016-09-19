$(function() {
  $(".review-selector").on('click', 'li', function () {
    // $(this).siblings().removeClass('active');
    // $(this).addClass('active');
    // $(this).closest('.review-question').find('.review-counter').addClass('complete');
    // $(this).closest('.review-question').find('.tell-us-why').slideDown();
  });
  $(".review-form-container").on('click', '.tell-us-link', function () {
    var text_link = $(this);
    text_link.slideUp('fast');
    text_link.siblings().slideDown('slow');
    var tell_us_text =$(text_link.siblings()[0]).find('textarea');
    tell_us_text.focus();
    tell_us_text.on('focusout',function(){
      if(tell_us_text.val().length == 0){
        text_link.slideDown('slow');
        text_link.siblings().slideUp('fast');
      }
    });
  });
});
