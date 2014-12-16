
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
                    $.ajax({
                        type: 'GET',
                        url: "/gsr/user/save_city_state",
                        data: {user: gon.current_user,city: $('#js-userCity').val(), state: state_abbr},
                        dataType: 'json',
                        async: true
                    }).done(function (data) {
                        console.log(data.error_msgs);

                    });
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