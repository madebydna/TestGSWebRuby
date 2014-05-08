GS.choosingDropdownInit = GS.choosingDropdownInit || function() {
  var expandToggle = function() {
    var closeRegex = new RegExp("Close.+");

    if(closeRegex.test($(this).text())) {
      $(this).html('Additional resources &raquo;');
    } else {
      $(this).html('Close &raquo;');
    }

    $(this).parent().find('.expandable').slideToggle();
  };

  $('.js-expand-collapse').each(function() {
    $(this).click(expandToggle);
  });
};


$(document).ready(function() {
  GS.choosingDropdownInit();
});
