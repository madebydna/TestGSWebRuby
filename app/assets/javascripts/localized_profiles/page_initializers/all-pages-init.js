$(function() {
    // even though this code is simple, I'd rather it be an actual module, i.e. GS.sendMeUpdates,
    // since it's easier to test
   $('.js-send-me-updates-button').on('click', function() {
      $('#js-send-me-updates-form').submit();
   });

   $('.js-save-this-school-button').on('click', function() {
      $('#js-save-this-school-form').submit();
   });
});