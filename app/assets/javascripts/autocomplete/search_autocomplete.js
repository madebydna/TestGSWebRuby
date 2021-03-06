GS.search = GS.search || {};
GS.search.autocomplete = GS.search.autocomplete || {};

GS.search.autocomplete.searchAutocomplete = GS.search.autocomplete.searchAutocomplete || (function($) {

    var init = function(state_abbr) {
        Handlebars.registerHelper('addLangToUrl', function(url) {
          return GS.uri.Uri.copyParam('lang', GS.uri.Uri.getHref(), url);
        });
        attachAutocomplete(state_abbr);
        attachAutocompleteHandlers();
    };
//
    var detachAutocomplete = function() {
        $('.typeahead').typeahead('destroy');
        $('.typeahead-nav').typeahead('destroy');
    };

//
    var cleardataSetBloodhounds = function (dataSets) {
        for (var i = 0; i < dataSets.length; i++) {
            var dataSet = dataSets[i];
            dataSet.clearBloodhound();
        }
    }

    var attachAutocomplete = function (state_abbr) {
        var state_query = typeof state_abbr === "string" ? '&state=' + state_abbr : '';
        var autocomplete = GS.search.autocomplete;
        var markup = autocomplete.display;
        var schools = autocomplete.data.init({tokenizedAttribute: 'school_name', defaultUrl: '/gsr/search/suggest/school?query=%QUERY' + state_query, sortFunction: false });
        var cities = autocomplete.data.init({tokenizedAttribute: 'city_name', defaultUrl: '/gsr/search/suggest/city?query=%QUERY' + state_query, displayLimit: 5 });
        var districts = autocomplete.data.init({tokenizedAttribute: 'district_name', defaultUrl: '/gsr/search/suggest/district?query=%QUERY' + state_query, displayLimit: 5 });
        var navSchools = autocomplete.data.init({tokenizedAttribute: 'school_name', defaultUrl: '/gsr/search/suggest/school?query=%QUERY', sortFunction: false });
        var navCities = autocomplete.data.init({tokenizedAttribute: 'city_name', defaultUrl: '/gsr/search/suggest/city?query=%QUERY', displayLimit: 5 });
        var navDistricts = autocomplete.data.init({tokenizedAttribute: 'district_name', defaultUrl: '/gsr/search/suggest/district?query=%QUERY', displayLimit: 5 });

        $('.typeahead-nav').typeahead({
          hint: true,
          highlight: true,
          minLength: 1
        },
          {
            name: 'cities', //for generated css class name. Ex tt-dataset-cities
            displayKey: 'city_name', //key whose value will be displayed in input
            source: navCities.ttAdapter(),
            clearBloodhound: navCities.ttAdapterClear(), //initialized Bloodhound clear method
            templates: markup.cityResultsMarkup()
          },
          {
            name: 'districts',
            displayKey: 'district_name',
            source: navDistricts.ttAdapter(),
            clearBloodhound: navDistricts.ttAdapterClear(),
            templates: markup.districtResultsMarkup()
          },
          {
            name: 'schools',
            displayKey: 'school_name',
            source: navSchools.ttAdapter(),
            clearBloodhound: navSchools.ttAdapterClear(),
            templates: markup.schoolResultsMarkup()
          }
        );
        $('.typeahead').typeahead({
            hint: true,
            highlight: true,
            minLength: 1
        },
            {
                name: 'cities', //for generated css class name. Ex tt-dataset-cities
                displayKey: 'city_name', //key whose value will be displayed in input
                source: cities.ttAdapter(),
                clearBloodhound: cities.ttAdapterClear(), //initialized Bloodhound clear method
                templates: markup.cityResultsMarkup()
            },
            {
                name: 'districts',
                displayKey: 'district_name',
                source: districts.ttAdapter(),
                clearBloodhound: districts.ttAdapterClear(),
                templates: markup.districtResultsMarkup()
            },
            {
                name: 'schools',
                displayKey: 'school_name',
                source: schools.ttAdapter(),
                clearBloodhound: schools.ttAdapterClear(),
                templates: markup.schoolResultsMarkup()
            }
        );
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
                var dataSets = this.dropdown.datasets;
                cleardataSetBloodhounds(dataSets);
                this.dropdown.empty();
                this.dropdown.close();
            } else if (query.length >= this.minLength) {
                this.dropdown.update(query);
                this.dropdown.open();
                this._setLanguageDirection();
            }
        });
    };

    return {
        init: init,
        detachAutocomplete: detachAutocomplete
    }
})(jQuery);
