jQuery(function() {
  jQuery('.js-zillowNearbyHomesForm').on('submit', function() {
    try {
      var $form = jQuery(this);
      var $minPriceSelect = $form.find('select.js-zillowMinPrice');
      var minPrice = $minPriceSelect.val();
      var maxPrice = ''; // max is next value in list, or blank if at first or last selection
      if (minPrice !== undefined && minPrice != '') {
        maxPrice = $minPriceSelect.find('option:selected').next().val() || '';
      }
      $form.find('.js-zillowMaxPrice').val(maxPrice);
    } catch (e) {
      // just let the form submit without a max price specified
    }
    return true;
  });
});