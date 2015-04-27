GS.search = GS.search || {};
GS.search.autocomplete = GS.search.autocomplete || {};

GS.search.autocomplete.display = GS.search.autocomplete.display || (function() {

    var schoolResultsMarkup = function() {
        return {
            suggestion: Handlebars.compile('<a href="{{url}}" class="tt-suggestion-link"><p class="tt-suggestion-text"><strong>{{school_name}}</strong><br><span class="tt-state-name">{{city_name}}, {{state}}</span></p></a>')
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
        districtResultsMarkup: districtResultsMarkup,
        cityResultsMarkup: cityResultsMarkup,
        cityChooserMarkup: cityChooserMarkup
    }

})();


GS.search.autocomplete.selectdisplay = GS.search.autocomplete.selectdisplay || (function() {

  var schoolResultsMarkup = function() {
   var queryString = "";
    var morganstanley = "";
    var topic = "";
    if(gon.morganstanley){
      queryString = "?morganstanley=1"
    }
    if (gon.topic) {
        if (queryString.length > 2) {
            queryString = queryString + "&topic="+ gon.topic
        }
        else {
            queryString = "?topic=" + gon.topic
        }
      }
    return {
      suggestion: Handlebars.compile('<a href="{{url}}reviews/'+queryString+'" class="tt-suggestion-link"><p class="tt-suggestion-text"><strong>{{school_name}}</strong><br><span class="tt-state-name">{{city_name}}, {{state}}</span></p></a>')
    }

  };

  return {
    schoolResultsMarkup: schoolResultsMarkup
  }

})();
