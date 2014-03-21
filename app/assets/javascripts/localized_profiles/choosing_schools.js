GS = GS || {};

GS.choosingDropdownInit = GS.choosingDropdownInit || function() {
  var expandClick = function() {
    $(this).text('Close »');
    $(this).parent().find('.expandable').slideToggle();
    $(this).unbind('click');
    $(this).click(collapseClick);
  };

  var collapseClick = function() {
    $(this).text('Additional resources »');
    $(this).parent().find('.expandable').slideToggle();
    $(this).unbind('click');
    $(this).click(expandClick);
  };

  $('.js-expand-collapse').each(function() {
    $(this).click(expandClick);
  });
};


$(document).ready(function() {
  GS.choosingDropdownInit();
});
