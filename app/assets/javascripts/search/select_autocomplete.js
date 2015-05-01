GS.search = GS.search || {};
GS.search.autocomplete = GS.search.autocomplete || {};

GS.search.autocomplete.selectAutocomplete = GS.search.autocomplete.selectAutocomplete || (function() {

  var init = function(state_abbr, markupCallback, onSelectCallback) {
    attachAutocomplete(state_abbr, markupCallback, onSelectCallback);
  };

  var attachAutocomplete = function (state_abbr, markupCallback, onSelectCallback) {
    var state_query = typeof state_abbr === "string" ? '&state=' + state_abbr : '';
    var autocomplete = GS.search.autocomplete;
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
        templates: markupCallback.call()
      }
    ).on('typeahead:selected', onSelectCallback)
  };

  return {
    init: init
  }
})();