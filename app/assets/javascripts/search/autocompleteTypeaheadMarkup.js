GS.search = GS.search || {};
GS.search.autocomplete = GS.search.autocomplete || {};

GS.search.autocomplete.display = GS.search.autocomplete.display || (function() {

    var schoolResultsMarkup = function() {
        return {
            suggestion: Handlebars.compile('<a href="{{url}}" class="tt-suggestion-link"><p class="tt-suggestion-text"><strong>{{school_name}}</strong><br><span class="tt-state-name">{{city_name}}, {{state}}</span></p></a>')
        }
    };

    var schoolResultsNoLinkMarkup = function() {
        return {
            suggestion: Handlebars.compile('<a class="tt-suggestion-link"><p class="tt-suggestion-text"><strong>{{school_name}}</strong><br><span class="tt-state-name">{{city_name}}, {{state}}</span></p></a>')
        }
    };

    var districtResultsMarkup = function() {
        return {
            suggestion: Handlebars.compile('<a href="{{url}}" class="tt-suggestion-link"><p class="tt-suggestion-text"><span class="tt-schools-in">Schools in</span> <strong>{{district_name}}, {{state}}</strong></p></a>')
        }
    };

    var cityResultsMarkup = function() {
        return {
            suggestion: Handlebars.compile('<a href="{{url}}" class="tt-suggestion-link"><p class="tt-suggestion-text"><span class="tt-schools-in">Schools in</span> <strong>{{city_name}}, {{state}}</strong></p></a>')
        }
    };

    var cityChooserMarkup = function() {
        return {
            suggestion: Handlebars.compile('<a class="tt-suggestion-link"><p class="tt-suggestion-text"><span class="tt-schools-in">My school is in</span> <strong>{{city_name}}, {{state}}</strong></p></a>')
        }
    };

    return {
        schoolResultsMarkup: schoolResultsMarkup,
        schoolResultsNoLinkMarkup: schoolResultsNoLinkMarkup,
        districtResultsMarkup: districtResultsMarkup,
        cityResultsMarkup: cityResultsMarkup,
        cityChooserMarkup: cityChooserMarkup
    }

})();

