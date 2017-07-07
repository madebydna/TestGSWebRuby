var GS = GS || {};
GS.multiSelectButtonGroup = GS.multiSelectButtonGroup || function() {
  var $label = jQuery(this);
  var $hiddenField = $label.closest('fieldset').find('input[type=hidden]');
  var values = $hiddenField.val().split(',');
  if ($hiddenField.val() == "") {
    values = [];
  }
  var value = $label.data('value').toString();
  var index = values.indexOf(value);
  if(index == -1) {
    values.push(value);
  } else {
    values.splice(index, 1);
  }
  $hiddenField.val(values.join(','));
  $label.toggleClass('active');
};
