$(function() {

  GS.ad.addCompfilterToGlobalAdTargetingGon();

  GS.search.autocomplete.searchAutocomplete.init();

  try {
    $('.neighborhood img[data-src]').unveil(300, function() {
      $(this).width('100%')
    });
  } catch (e) {}
  try {
    $('.innovate-logo').unveil(300);
  } catch (e) {}

});
