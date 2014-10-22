GS.search = GS.search || {};
GS.search.autocomplete = GS.search.autocomplete || {};

GS.search.autocomplete.searchAutocomplete = GS.search.autocomplete.searchAutocomplete || (function() {

    var init = function(state_abbr) {
        attachAutocomplete(state_abbr);
        attachAutocompleteHandlers();
    };

    var attachAutocomplete = function (state_abbr) {
        var state = typeof state_abbr === "string" ? state_abbr : 'de';
        var autocomplete = GS.search.autocomplete;
        var markup = autocomplete.display;
        var schools = autocomplete.data.init({tokenizedAttribute: 'school_name', defaultUrl: '/gsr/search/suggest/school?query=%QUERY&state=' + state, sortFunction: false });
        var cities = autocomplete.data.init({tokenizedAttribute: 'city_name', defaultUrl: '/gsr/search/suggest/city?query=%QUERY&state=' + state, displayLimit: 5 });
        var districts = autocomplete.data.init({tokenizedAttribute: 'district_name', defaultUrl: '/gsr/search/suggest/district?query=%QUERY&state=' + state, displayLimit: 5 });
        $('.typeahead').typeahead({
            hint: true,
            highlight: true,
            minLength: 1
        },
            {
                name: 'cities', //for generated css class name. Ex tt-dataset-cities
                displayKey: 'city_name', //key whose value will be displayed in input
                source: cities.ttAdapter(),
                templates: markup.cityResultsMarkup(state)
            },
            {
                name: 'districts',
                displayKey: 'district_name',
                source: districts.ttAdapter(),
                templates: markup.districtResultsMarkup(state)
            },
            {
                name: 'schools',
                displayKey: 'school_name',
                source: schools.ttAdapter(),
                templates: markup.schoolResultsMarkup(state)
            }
        ).on('typeahead:selected', function (event, suggestion, dataset) {
            GS.uri.Uri.goToPage(suggestion['url']);
        })
    };

    var attachAutocompleteHandlers = function() {
        var autocomplete = GS.search.autocomplete;
        autocomplete.handlers.setOnUpKeyedCallback();
        autocomplete.handlers.setOnQueryChangedCallback();
        autocomplete.handlers.setOnDownKeyedCallback();
    };

    return {
        init: init
    }
})();