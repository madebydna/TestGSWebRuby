Array.prototype.contains = function(obj) {
  var i = this.length;
  while (i--) {
    if (this[i] === obj) {
      return true;
    }
  }
  return false;
};

var GS = GS || {};
GS.search = GS.search || {};
GS.search.schoolSearchForm = GS.search.schoolSearchForm || (function() {
    var SEARCH_PAGE_PATH = '/search/search.page';
    var findByNameSelector = 'input#js-findByNameBox';
    var findByLocationSelector = 'input#js-findByLocationBox';

    var init = function(state) {
        $('#js-findByLocationForm').submit(function() {
            try {
                return submitByLocationSearch.apply(this);
            } catch(e) {
                console.log(e.message);
                return false;
            }
        });

        $('#js-findByNameForm').submit(function() {
            try {
                return submitByNameSearch.apply(this);
            } catch(e) {
                console.log(e.message);
                return false;
            }
        });
    };

    var isTermState = function(term) {
        var stateTermList = new Array
                ("AK","Alaska","AL","Alabama","AR","Arkansas","AZ","Arizona",
                        "CA","California","CO","Colorado","CT","Connecticut","DC",
                "DE","Delaware","FL","Florida","GA","Georgia","HI","Hawaii","IA","Iowa",
                "ID","Idaho","IL","Illinois","IN","Indiana","KS","Kansas","KY","Kentucky",
                "LA","Louisiana","MA","Massachusetts","MD","Maryland","ME","Maine","MI","Michigan",
                "MN","Minnesota","MO","Missouri","MS","Mississippi","MT","Montana",
                "NC","North Carolina","ND","North Dakota","NE","Nebraska","NH","New Hampshire",
                "NJ","New Jersey","NM","New Mexico","NV","Nevada","NY","New York",
                "OH","Ohio","OK","Oklahoma","OR","Oregon","PA","Pennsylvania",
                "RI","Rhode Island","SC","South Carolina","SD","South Dakota",
                "TN","Tennessee","TX","Texas","UT","Utah","VA","Virginia","VT","Vermont",
                "WA","Washington","WI","Wisconsin","WV","West Virginia","WY","Wyoming");
        for (var i=0; i < stateTermList.length; i++) {
            if (stateTermList[i].toLowerCase() == term.toLowerCase()) {
                return true;
            }
        }
        return false;
    };



    var submitByLocationSearch = function() {
        var searchQuery = $(this).find(findByLocationSelector).val();
        searchQuery = searchQuery.replace(/^\s*/, "").replace(/\s*$/, "");

        if (searchQuery != '' &&
                searchQuery != 'Search by city AND state or address ...' && !isTermState(searchQuery)) {
            $(this).find(findByLocationSelector).val(searchQuery);

            //GS-12100 Since its a by location search, strip the words 'schools' from google geocode searches.
            var searchQueryWithFilteredStopWords = searchQuery;
            if (searchQueryWithFilteredStopWords != '') {
                searchQueryWithFilteredStopWords = searchQueryWithFilteredStopWords.replace(/schools/g, "");
            }

            gsGeocode(searchQueryWithFilteredStopWords, function(geocodeResult) {
                if (geocodeResult != null) {
                    var data = {};
                    data['lat'] = geocodeResult['lat'];
                    data['lon'] = geocodeResult['lon'];
                    data['zipCode'] = geocodeResult['zipCode'];
                    data['state'] = geocodeResult['state'];
                    data['locationType'] = geocodeResult['type'];
                    data['normalizedAddress'] = geocodeResult['normalizedAddress'];
                    data['totalResults'] = geocodeResult['totalResults'];
                    data['locationSearchString'] = searchQuery;
                    data['distance'] = 5;
                    data['city'] = geocodeResult['city'];
                    data['sortBy'] = 'DISTANCE';

                    window.location.href = window.location.protocol + '//' + window.location.host +
                            SEARCH_PAGE_PATH +
                            GS.uri.Uri.getQueryStringFromObject(data);
                } else {
                    alert("Location not found. Please enter a valid address, city, or ZIP.");
                }
            });
        } else {
            alert("Please enter an address, zip code or city and state");
        }

        return false;
    };

    var formatNormalizedAddress = function(address) {
        var newAddress = address.replace(", USA", "");
        var zipCodePattern = /(\d\d\d\d\d)-\d\d\d\d/;
        var matches = zipCodePattern.exec(newAddress);
        if (matches && matches.length > 1) {
            newAddress = newAddress.replace(zipCodePattern, matches[1]);
        }
        return newAddress;
    };

    var gsGeocode = function(searchInput, callbackFunction) {
        var geocoder = new google.maps.Geocoder();
        if (geocoder && searchInput) {
            geocoder.geocode( { 'address': searchInput, 'componentRestrictions': { 'country': 'US' }}, function(results, status) {
                var GS_geocodeResults = new Array();
                if (status == google.maps.GeocoderStatus.OK && results.length > 0) {
                    for (var x = 0; x < results.length; x++) {
                        var geocodeResult = new Array();
                        geocodeResult['lat'] = results[x].geometry.location.lat();
                        geocodeResult['lon'] = results[x].geometry.location.lng();
                        geocodeResult['normalizedAddress'] = formatNormalizedAddress(results[x].formatted_address);
                        geocodeResult['type'] = results[x].types.join();
                        if (results[x].partial_match) {
                            geocodeResult['partial_match'] = true;
                        } else {
                            geocodeResult['partial_match'] = false;
                        }
                        for (var i = 0; i < results[x].address_components.length; i++) {
                            if (results[x].address_components[i].types.contains('administrative_area_level_1')) {
                                geocodeResult['state'] = results[x].address_components[i].short_name;
                            }
                            if (results[x].address_components[i].types.contains('country')) {
                                geocodeResult['country'] = results[x].address_components[i].short_name;
                            }
                            if (results[x].address_components[i].types.contains('postal_code')) {
                                geocodeResult['zipCode'] = results[x].address_components[i].short_name;
                            }
                            if (results[x].address_components[i].types.contains('locality')) {
                                geocodeResult['city'] = results[x].address_components[i].long_name;
                            }
                        }
                        // http://stackoverflow.com/questions/1098040/checking-if-an-associative-array-key-exists-in-javascript
                        if (!('lat' in geocodeResult && 'lon' in geocodeResult &&
                                'state' in geocodeResult &&
                                'normalizedAddress' in geocodeResult &&
                                'country' in geocodeResult)) {
                            geocodeResult = null;
                        }
                        if (geocodeResult != null) {
                            GS_geocodeResults.push(geocodeResult);
                        }
                    }
                }
                if (GS_geocodeResults.length == 0) {
                    callbackFunction(null);
                } else {
                    // ignore multiple results
                    GS_geocodeResults[0]['totalResults'] = GS_geocodeResults.length;
                    callbackFunction(GS_geocodeResults[0]);
                }
            });
        }
    };

    var submitByNameSearch = function() {
        var searchString = $(this).find(findByNameSelector).val();
        var state = $(this).find('input#js-state').val();
        var collectionId = $(this).find('input#js-collectionId').val();
        var queryString = GS.uri.Uri.getQueryData();

        queryString.q = encodeURIComponent(searchString);
        queryString.collectionId = encodeURIComponent(collectionId);
        queryString.state = encodeURIComponent(state);

        window.location = window.location.protocol + '//' + window.location.host +
                SEARCH_PAGE_PATH +
                GS.uri.Uri.getQueryStringFromObject(queryString);
        return false;
    };

    return {
        init:init,
        submitByLocationSearch: submitByLocationSearch,
        submitByNameSearch: submitByNameSearch,
        gsGeocode: gsGeocode
    };
})();

$(document).ready(function() {
  GS.search.schoolSearchForm.init();
});
