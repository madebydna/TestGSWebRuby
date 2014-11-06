GS.search = GS.search || {};
GS.search.autocomplete = GS.search.autocomplete || {};

GS.search.autocomplete.selectAutocomplete = GS.search.autocomplete.selectAutocomplete || (function() {

  var init = function(state_abbr) {
    attachAutocomplete(state_abbr);
    attachAutocompleteHandlers();
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
        templates: markup.schoolResultsMarkup()
      }
    ).on('typeahead:selected', function (event, suggestion, dataset) {
        GS.uri.Uri.goToPage(suggestion['url']);
      });
  };

  var attachAutocompleteHandlers = function() {
    setOnUpKeyedCallbackForSearch();
    setOnQueryChangedCallbackForSearch();
    setOnDownKeyedCallbackForSearch();
  };

  var setOnUpKeyedCallbackForSearch = function() {
    var isAddress = GS.search.schoolSearchForm.isAddress;
    GS.search.autocomplete.handlers.setOnUpKeyedCallback(function(query) {

      if (isAddress(query)) {
        this.dropdown.close();
      } else if (this.dropdown.isEmpty && query.length >= this.minLength) {
        this.dropdown.update(query);
        this.dropdown.open();
      } else {
        this.dropdown.moveCursorUp();
        this.dropdown.open();
      }
    });
  };

  var setOnDownKeyedCallbackForSearch = function() {
    var isAddress = GS.search.schoolSearchForm.isAddress;
    GS.search.autocomplete.handlers.setOnDownKeyedCallback(function(query) {
      if (isAddress(query)) {
        this.dropdown.close();
      } else if (this.dropdown.isEmpty && query.length >= this.minLength) {
        this.dropdown.update(query);
        this.dropdown.open();
      } else {
        this.dropdown.moveCursorDown();
        this.dropdown.open();
      }
    });
  };

  var setOnQueryChangedCallbackForSearch = function() {
    var isAddress = GS.search.schoolSearchForm.isAddress;
    GS.search.autocomplete.handlers.setOnQueryChangedCallback(function(query) {

      this.input.clearHintIfInvalid();
      if (isAddress(query) || query.length == 0) {
        this.dropdown.close();
      } else if (query.length >= this.minLength) {
        this.dropdown.update(query);
        this.dropdown.open();
        this._setLanguageDirection();
      }
    });
  };

  return {
    init: init
  }
})();