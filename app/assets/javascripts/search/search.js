Array.prototype.contains = function(obj) {
  var i = this.length;
  while (i--) {
    if (this[i] === obj) {
      return true;
    }
  }
  return false;
};

GS.search = GS.search || {};

GS.search.assignedSchools = GS.search.assignedSchools || (function() {
    var shouldGetAssignedSchools = function() {
        if (gon.pagename != 'SearchResultsPage') {
            return false;
        }

        var pageNumber = GS.uri.Uri.getFromQueryString('page');
        if (pageNumber && pageNumber != '1') {
            return false;
        }

        var isSearchSpecificEnough = false;

        // TODO: Replace this prototype logic with the real thing (tm)
        if (GS.uri.Uri.getFromQueryString("assignedSchool")) {
            isSearchSpecificEnough = true;
        }
        return isSearchSpecificEnough;
    };

    var getAssignedSchools = function() {
        var lat = GS.uri.Uri.getFromQueryString("lat");
        var lon = GS.uri.Uri.getFromQueryString("lon");
        var grade = GS.uri.Uri.getFromQueryString("grades");
        if (!lat || !lon) {
            return;
        }
        var data = {lat: lat, lon: lon};
        var gradeToLevelMap = {
            'k': 'e', '1': 'e', '2': 'e', '3': 'e', '4': 'e', '5': 'e',
            '6': 'm', '7': 'm', '8': 'm',
            '9': 'h', '10': 'h', '11': 'h', '12': 'h'
        };
        if (grade && gradeToLevelMap[grade]) {
            data.level = gradeToLevelMap[grade];
        }
        jQuery.getJSON("/geo/boundary/ajax/getAssignedSchoolByLocation.json", data, function(data) {
            if (data && data.results && data.results.length) {
                for (var x=0; x < data.results.length; x++) {
                    var schoolWrapper = data.results[x];
                    if (schoolWrapper.schools && schoolWrapper.schools.length) {
                        try {
                            setAssignedSchool(schoolWrapper.level, schoolWrapper.schools[0]);
                        } catch (e) {
                            // on any error just ignore it and move on
                        }
                    } else {
                        setNoAssignedSchools();
                    }
                }
            }
        });
    };

    var setAssignedSchool = function(levelCode, school) {
        if (school.id) {
            setAssignedSchoolInMap(levelCode, school.id);
            setAssignedSchoolInList(levelCode, school);
        }
    };

    var setAssignedSchoolInMap = function(levelCode, schoolId) {
        var level = 'elementary';
        if (levelCode == 'm') {
            level = 'middle';
        } else if (levelCode == 'h') {
            level = 'high';
        }
        GS.search.googleMap.setAssignedSchool(schoolId, level);
    };

    var setAssignedSchoolInList = function(levelCode, school) {
        var level = 'elementary';
        if (levelCode == 'm') {
            level = 'middle';
        } else if (levelCode == 'h') {
            level = 'high';
        }
        var listItemSelector = '#js-assigned-school-' + level;

        var listItem = $(listItemSelector);

        var distance = Math.round(school.distance * 100) / 100;
        var gradeRange = school.gradeRange;
        var name = school.name;
        var numReviews = school.numReviews;
        var parentRating = school.parentRating;
        var gsRating = school.rating;
        var type = school.schoolType;
        var state = school.state;
        var zip = school.address.zip;
        if (type == 'public') {
            type = 'public district';
        }
        type = type.charAt(0).toUpperCase() + type.slice(1);
        var url = school.url;
        var reviewsUrl = school.url + 'reviews/';
        var qualityUrl = school.url + 'quality/';
        var address = school.address.street1 + ' ' + school.address.cityStateZip;

        listItem.find('.js-name').html(name).attr('href', url);
        listItem.find('.js-address').html(address);
        listItem.find('.js-type').html(type);
        listItem.find('.js-grade-range').html(gradeRange);
        listItem.find('.js-distance').html(distance + ' miles');
        if (parentRating && parentRating > 0 && parentRating < 6) {
            var orangeStar = listItem.find('.js-parent-rating-stars .i-16-orange-star');
            var greyStar = listItem.find('.js-parent-rating-stars .i-16-grey-star');
            orangeStar.removeClass('i-16-star-1').addClass('i-16-star-' + parentRating);
            greyStar.removeClass('i-16-star-4').addClass('i-16-star-' + (5-parentRating));
        } else {
            listItem.find('.js-parent-rating-stars').hide();
        }
        if (numReviews) {
            var reviewWord = ' review';
            if (numReviews > 1) {
                reviewWord = ' reviews';
            }
            listItem.find('.js-review-count').html(numReviews + reviewWord).attr('href', reviewsUrl);
            listItem.find('.js-no-reviews').hide();
        } else {
            listItem.find('.js-review-count').hide();
            listItem.find('.js-no-reviews').show();
        }
        if (gsRating && gsRating > 0 && gsRating < 11) {
            var gsRatingLink = listItem.find('.js-gs-rating-link');
            gsRatingLink.attr('href', qualityUrl).find('.iconx24-icons').removeClass('i-24-new-ratings-nr').addClass('i-24-new-ratings-' + gsRating);
        }

        listItem.find('.js-homes-for-sale').attr('href', 'http://www.zillow.com/' + state + '-' + zip + '?cbpartner=Great+Schools&utm_source=Great_Schools&utm_medium=referral&utm_campaign=schoolsearch');

        listItem.show('slow');
    };

    var setNoAssignedSchools = function() {
        // TODO
    };

    return {
        shouldGetAssignedSchools:shouldGetAssignedSchools,
        getAssignedSchools: getAssignedSchools
    };
})();

GS.search.schoolSearchForm = GS.search.schoolSearchForm || (function(state_abbr) {
    var SEARCH_PAGE_PATH = '/search/search.page';
    var findByNameSelector = 'input#js-findByNameBox';
    var findByLocationSelector = 'input#js-findByLocationBox';
    var schoolResultsSearchSelector = 'input#js-schoolResultsSearch';
    var locationSelector = '.search-type-toggle div:first-child';
    var nameSelector = '.search-type-toggle div:last-child';
    var searchType = 'byName';
    var state = state_abbr ;

    var init = function() {
        $('.js-findByLocationForm').submit(function() {
            var input = $(this).find(findByLocationSelector)[0];
            var valid = validateField(input, input['defaultValue']);
            if (valid) {
                return submitByLocationSearch.apply(this);
            } else {
                return false;
            }
        });

        $('.js-findByNameForm').submit(function() {
            var input = $(this).find(findByNameSelector)[0];
            var valid = validateField(input, input['defaultValue']);
            if (valid) {
                return submitByNameSearch.apply(this);
            } else {
                return false;
            }
        });

        $('.js-schoolResultsSearchForm').submit(function() {
            var input = $(this).find(schoolResultsSearchSelector)[0];
            var valid = validateField(input, input['placeholder']);
            isAddress(input.value);
            var searchType = GS.search.schoolSearchForm.searchType;
            if (valid) {
                var searchOptions = {};
                var gradeLevelFilter = $('#js-searchGradeLevelFilter');
                if (gradeLevelFilter.length > 0 && gradeLevelFilter.val() != '') {
                    searchOptions['grades'] = gradeLevelFilter.val();
                }

                if (input.value == $(schoolResultsSearchSelector).data('prev-search')) {
                    $.cookie('showFiltersMenu', 'true', {path: '/'});
                    var params = GS.uri.Uri.removeFromQueryString(window.location.search, 'grades');
                    params = GS.uri.Uri.removeFromQueryString(params, 'page');
                    params = GS.uri.Uri.putParamObjectIntoQueryString(params, searchOptions);
                    var url = window.location.protocol + '//' + window.location.host + GS.uri.Uri.getPath() + params;
                    GS.uri.Uri.goToPage(url);
                    return false
                } else if (searchType == 'byLocation') {
                    GS.search.schoolSearchForm.findByLocationSelector = schoolResultsSearchSelector;
                    $.cookie('showFiltersMenu', 'true', {path: '/'});
                    return submitByLocationSearch.apply(this);
                } else if (searchType == 'byName') {
                    GS.search.schoolSearchForm.findByNameSelector = schoolResultsSearchSelector;
                    GS.uri.Uri.addHiddenFieldsToForm({state: state}, this);
                    $.cookie('showFiltersMenu', 'true', {path: '/'});
                    return submitByNameSearch.call(this, searchOptions);
                } else {
                    return false;
                }
            } else {
                return false;
            }
        });

        try {
            if (GS.search.assignedSchools.shouldGetAssignedSchools()) {
                GS.search.assignedSchools.getAssignedSchools();
            }
        } catch (e) {
            // ignore. This is prototype code
        }
    };

    var setupTabs = function() {
        $(locationSelector).click(function() {
            $(this).addClass('selected');
            $('.location-search').show();
            $(nameSelector).removeClass('selected');
            $('.name-search').hide();
        });
        $(nameSelector).click(function() {
            $(this).addClass('selected');
            $('.name-search').show();
            $(locationSelector).removeClass('selected');
            $('.location-search').hide();
        });
    };

    var validateField = function(field, valueToIgnore) {
        if (valueToIgnore && field['value'] == valueToIgnore) {
            return false;
        }

        if (field['value'].length == 0) {
            return false;
        }

        if (/^\s+$/.test(field['value'])) {
            return false;
        }

        return true;
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

    var submitByLocationSearch = function(geocodeCallbackFn) {
        var searchQuery = getSearchQuery();
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
//                    data['locationType'] = geocodeResult['type'];
                    data['normalizedAddress'] = geocodeResult['normalizedAddress'];
//                    data['totalResults'] = geocodeResult['totalResults'];
                    data['city'] = geocodeResult['city'];
                    data['sortBy'] = 'DISTANCE';
                    (geocodeCallbackFn || defaultGeocodeCallbackFn)(data);
                } else {
                    alert("Location not found. Please enter a valid address, city, or ZIP.");
                }
            });
        } else {
            alert("Please enter an address, zip code or city and state");
        }

        return false;
    };

    var getSearchQuery = function() {
        var searchQuery = $(GS.search.schoolSearchForm.findByLocationSelector).val();
        return searchQuery.replace(/^\s*/, "").replace(/\s*$/, "");
    };

    var defaultGeocodeCallbackFn = function(geocodeResult) {
        var searchOptions = jQuery.extend({}, geocodeResult);
        for (var urlParam in searchOptions) {
            if (searchOptions.hasOwnProperty(urlParam)) {
                searchOptions[urlParam] = encodeURIComponent(searchOptions[urlParam]);
            }
        }
        searchOptions['locationSearchString'] = encodeURIComponent(getSearchQuery());
        searchOptions['distance'] = $('#js-distance-select-box').val() || 5;
        var gradeLevelFilter = $('#js-searchGradeLevelFilter');
        if (gradeLevelFilter.length > 0 && gradeLevelFilter.val() != '') {
            searchOptions['grades'] = gradeLevelFilter.val();
        }

        // Not setting a timeout breaks back button
        setTimeout(function() { GS.uri.Uri.goToPage(window.location.protocol + '//' + window.location.host +
            SEARCH_PAGE_PATH +
            GS.uri.Uri.getQueryStringFromObject(searchOptions)); }, 1);
    };


    var isAddress = function (query) {
        var is_ad = false;

        is_ad = is_ad || matchesAddress(query);
        is_ad = is_ad || matchesFiveDigits(query);
        is_ad = is_ad || matchesFiveDigitsPlusFourDigits(query);

        GS.search.schoolSearchForm.searchType = is_ad ? 'byLocation' : 'byName';
        return is_ad
    };

    //Matches only 5 digits
    //Todo currently 3-4 schools would match this regex, but it may not be worth maintain a list of those schools to prevent matches
    var matchesFiveDigits = function (query) {
        return /(\D|^)\d{5}(\D*$|$)/.test(query)
    };

    //Matches 5 digits + dash or space or no space + 4 digits.
    var matchesFiveDigitsPlusFourDigits = function (query) {
        return /(\D|^)\d{5}(-|\s*)\d{4}(\D|$)/.test(query);
    };

    //Matches when first character/characters are numbers + a space + if it does not match schools in the school and district list.
    //ToDo perhaps not worth maintaining list of 300 schools for this regex.
    //ToDo if we do decide to maintain the list, perhaps move this into a service that autogenerates the list
    var matchesAddress = function(query) {
//        return (matchesNumbersAsOnlyFirstCharacters(query) && !matchesSchoolsList(query) && !matchesDistrictsList(query))
        return (matchesNumbersAsOnlyFirstCharacters(query));
    };

    var matchesNumbersAsOnlyFirstCharacters = function(query) {
        return /^\W*\d+\s/.test(query);
    };

    //there are about 300 schools that will accidentally generate a false positive on the address detection regex
    //if we want to support not matching on these schools then we will need to generate a list of these schools for the regex to check
    var matchesSchoolsList = function(query) {
        return new RegExp(query, 'i').test(schoolsList);
    };

    //there are about 3 districts that will accidentally generate a false positive on the address detection regex
    //if we want to support not matching on these districts then we will need to add this check to the mattches address regex above
    var matchesDistrictsList = function(query) {
        return new RegExp(query, 'i').test(districtsList);
    };

    var getSchoolsList = function() {
        var schools = [
            '3 To 5 Pre-School',
            '100 BLK Men of Greater Mobile\'s Phoenix Program',
            '2 Kool 4 Skool Learning Center',
            '1 Step At A Time Day Care',
            '2 B Kids',
            'etc....'
            //300 more schools that will accidentally match regex algorithm
        ];
        return schools.join("|")
    };

    var schoolsList = getSchoolsList();

    var getDistrictsList = function() {
        var districts = [
            '302 - K12 FLORIDA, LLC',
            '301 - FLORIDA CONNECTIONS',
            '100 Legacy Academy Charter School'
        ];
        return districts.join("|");
    };

    var districtsList = getDistrictsList();

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
            geocoder.geocode( { 'address': searchInput + ' US'}, function(results, status) {
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
                            'country' in geocodeResult)||
                            geocodeResult['country'] != 'US') {
                            geocodeResult = null;
                        }
                        if ( geocodeResult != null &&  state !=null && geocodeResult['state'] != state.toUpperCase()){
                            geocodeResult = null;
                        }
                        if (geocodeResult != null) {
                            GS_geocodeResults.push(geocodeResult);
                        }
                    }
                }
                if (GS_geocodeResults.length == 0) {
                    callbackFunction(null);
                }
                else if (GS_geocodeResults.length == 1) {
                    GS_geocodeResults[0]['totalResults'] = 1;
                    callbackFunction(GS_geocodeResults[0]);
                }
                else {
                    // ignore multiple results
                    GS_geocodeResults[0]['totalResults'] = GS_geocodeResults.length;
                    callbackFunction(GS_geocodeResults[0]);
                }
            });
        }
    };

    var submitByNameSearch = function(queryStringOptions) {
        var searchString = $(this).find(GS.search.schoolSearchForm.findByNameSelector).val();
//        TODO temporarily added find('[name=state]')
        var state = $(this).find('input#js-state').val() || $(this).find('[name=state]').val();
        var collectionId = $(this).find('input#js-collectionId').val();
        var queryString = jQuery.extend({}, queryStringOptions);

        queryString.q = encodeURIComponent(searchString);
        if (typeof collectionId !== 'undefined') {
            queryString.collectionId = collectionId;
        }
        if (typeof state !== 'undefined') {
            queryString.state = state;
        }

        setTimeout(function() { GS.uri.Uri.goToPage(window.location.protocol + '//' + window.location.host +
                SEARCH_PAGE_PATH +
                GS.uri.Uri.getQueryStringFromObject(queryString)); }, 1);
        return false;
    };

    var showFiltersMenuOnLoad = function() {
        if($.cookie('showFiltersMenu') == 'true' || $.cookie('showFiltersMenu') == undefined){
            if ($(document).width() > GS.window.sizing.maxMobileWidth && searchResultsDisplayed() ) {
                $('.js-searchFiltersMenu').show();
            }
        }
        $.cookie('showFiltersMenu', 'false', {path:'/'});
    };

    var searchResultsDisplayed = function() {
        return $('.js-searchResultsContainer').length > 0
    };


    var checkGooglePlaceholderTranslate = function () {
        var placeholder = $('#js-schoolResultsSearch').attr('placeholder');
        var translatedPlaceholder = $('.js-translate-placeholder').attr('font');
        if (placeholder != translatedPlaceholder) {
            $('#js-schoolResultsSearch').attr('placeholder', $('.js-translate-placeholder').text());
            setTimeout(checkGooglePlaceholderTranslate, 1000);
        } else {
            setTimeout(checkGooglePlaceholderTranslate, 1000);
        }
    };

    return {
        init:init,
        setupTabs: setupTabs,
        submitByLocationSearch: submitByLocationSearch,
        submitByNameSearch: submitByNameSearch,
        getSearchQuery: getSearchQuery,
        gsGeocode: gsGeocode,
        isAddress: isAddress,
        searchType: searchType,
        findByNameSelector: findByNameSelector,
        findByLocationSelector: findByLocationSelector,
        showFiltersMenuOnLoad: showFiltersMenuOnLoad,
        checkGooglePlaceholderTranslate: checkGooglePlaceholderTranslate
    };
})(gon.state_abbr);

GS.search.init = (function() {
  var self=this;
  if(typeof self.need_init==='undefined'){
    self.need_init='search already initialized';
    GS.search.schoolSearchForm.init();
    GS.search.schoolSearchForm.setupTabs();
    GS.search.schoolSearchForm.showFiltersMenuOnLoad();
    GS.search.schoolSearchForm.checkGooglePlaceholderTranslate();
  }
});
