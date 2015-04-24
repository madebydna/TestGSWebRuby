GS.search = GS.search || {};
GS.search.autocomplete = GS.search.autocomplete || {};

GS.search.autocomplete.selectAutocomplete = GS.search.autocomplete.selectAutocomplete || (function() {

  var init = function(state_abbr) {
    attachAutocomplete(state_abbr);
  };

  var attachAutocomplete = function (state_abbr) {
    var state_query = typeof state_abbr === "string" ? '&state=' + state_abbr : '';
    var autocomplete = GS.search.autocomplete;
    var markup = autocomplete.selectdisplay;
    var schools = autocomplete.data.init({tokenizedAttribute: 'school_name', defaultUrl: '/gsr/search/suggest/school?query=%QUERY' + state_query, sortFunction: false });
   $('.typeahead').typeahead({
        hint: true,
        highlight: true,
        minLength: 1
      },
      {
        name: 'schools',
        displayKey: 'school_name',
        source: schools.ttAdapter(),
        clearBloodhound: schools.ttAdapterClear(),
        templates: markup.schoolResultsMarkup()
      }
    ).on('typeahead:selected', function (event, suggestion, dataset) {
        GS.uri.Uri.goToPage(suggestion['url']+"reviews/");
      });
  };

  return {
    init: init
  }
})();