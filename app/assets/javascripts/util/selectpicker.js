GS = GS || {};
GS.selectpicker = GS.selectpicker || (function() {
  var selectpickerButtons = 'button.selectpicker';
  var selectpickerSelects = 'select.selectpicker';

  // Bootstrap Select (aka selectpicker) does not pass data attributes through.
  // This function grabs them off of the original select options and moves them
  // on to the corresponding <a>'s that Bootstrap Select creates.
  var updateDataAttributes = function() {
     $(window).on('load.bs.select.data-api', function () {
       _($(selectpickerButtons)).forEach(function(button) {
         var $button = $(button);
         var id = $button.data('id');
         var $selectpickerSelect = $(selectpickerSelects + '#' + id);
         var $selectpickerOptions = $selectpickerSelect.children('option');
         _($selectpickerOptions).forEach(function(option, index) {
           var newData = $(option).data();
           var $correspondingLi = correspondingLi($button, index);
           $correspondingLi.find('a').data(newData);
         });
       });
     })
  };

  var correspondingLi = function($selectpickerButton, index) {
    return $selectpickerButton
      .siblings('.dropdown-menu')
      .children('ul.selectpicker')
      .children('li[data-original-index="'+ index +'"]');
  };

  return {
    updateDataAttributes: updateDataAttributes,
  };

})();
