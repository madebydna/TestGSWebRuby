
GS.search = GS.search || {};
GS.search.autocomplete = GS.search.autocomplete || {};

GS.search.autocomplete.cityAutocomplete = GS.search.autocomplete.cityAutocomplete || (function() {

    var init = function(state_abbr) {
        attachAutocomplete(state_abbr);
    };

    var attachAutocomplete = function (state_abbr) {
        var state_query = typeof state_abbr === "string" ? '&state=' + state_abbr : '';
        var autocomplete = GS.search.autocomplete;
        var markup = autocomplete.display;
        var cities = autocomplete.data.init({tokenizedAttribute: 'city_name', defaultUrl: '/gsr/search/suggest/city?query=%QUERY' + state_query, displayLimit: 5 });
        $('.typeahead').typeahead({
                hint: true,
                highlight: true,
                minLength: 1
            },
            {
                name: 'cities',
                displayKey: 'city_name',
                source: cities.ttAdapter(),
                clearBloodhound: cities.ttAdapterClear(),
                templates: markup.cityChooserMarkup()
            }
        ).on('typeahead:selected', function (event, suggestion, dataset) {
//                TODO put where to save the data
                    console.log('I clicked on a city with a school');
        });
    };

    var detachAutocomplete = function() {
        $('.typeahead').typeahead('destroy');
    };

    var setUserAccountStatePickerHandler = function() {
        $('.js-changeSearchState').on('click', function() {
            var state = $(this).data().abbreviation;
            detachAutocomplete();
            init(state);
            $('.js-currentLocationText').html($(this).text());
        });
    };

    return {
        init: init,
        setUserAccountStatePickerHandler: setUserAccountStatePickerHandler
    }
})();