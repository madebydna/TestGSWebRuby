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

GS.search.stateAbbreviation = gon.state_abbr;

GS.search.schoolSearchForm = GS.search.schoolSearchForm || (function() {
    var SEARCH_PAGE_PATH = '/search/search.page';
    var findByNameSelector = 'input#js-findByNameBox';
    var findByLocationSelector = 'input#js-findByLocationBox';
    var schoolResultsSearchSelector = 'input#js-schoolResultsSearch';
    var locationSelector = '.search-type-toggle div:first-child';
    var nameSelector = '.search-type-toggle div:last-child';
    var searchType = 'byName';

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
          // forcing location search on home page button click.  Select will do direct linking.
            if($(this).find('.js-forceLocationSearch').length !== 0){
              GS.search.schoolSearchForm.searchType = 'byLocation';
            }
            else{
              isAddress(input.value);
            }

            var searchType = GS.search.schoolSearchForm.searchType;
            // PT-903. We are now loading Google Maps API asynchronously.
            // If it does not come back by the time someone searches:
            // we wait 200ms, look again, and default to byName search if it still has not loaded.
            // byName searches require a state, so we default to California if there is no state.
            if (typeof google === 'undefined' || typeof google.maps === 'undefined') {
                setTimeout( function() {
                    if (typeof google === 'undefined' || typeof google.maps === 'undefined') {
                        searchType = 'byName';
                        GS.search.stateAbbreviation = GS.search.stateAbbreviation || 'ca';
                    }
                }, 200);
            }

            if (valid) {
                var searchOptions = {};

                if (input.value == $(schoolResultsSearchSelector).data('prev-search') && GS.search.stateAbbreviation == $(schoolResultsSearchSelector).data('state')) {
                    $.cookie('showFiltersMenu', 'true', {path: '/'});
                    var params = GS.uri.Uri.removeFromQueryString(window.location.search, 'page');
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
                    GS.uri.Uri.addHiddenFieldsToForm({state: GS.search.stateAbbreviation}, this);
                    $.cookie('showFiltersMenu', 'true', {path: '/'});
                    return submitByNameSearch.call(this, searchOptions);
                } else {
                    return false;
                }
            } else {
                return false;
            }
        });
        GS.search.schoolSearchForm.placeholderMobile();
        GS.search.schoolSearchForm.checkGooglePlaceholderTranslate(); // all
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

    var STATE_NAME_MAP = {
        "AK":"Alaska","AL":"Alabama","AR":"Arkansas","AZ":"Arizona",
        "CA":"California","CO":"Colorado","CT":"Connecticut","DC":"District of Columbia",
        "DE":"Delaware","FL":"Florida","GA":"Georgia","HI":"Hawaii","IA":"Iowa",
        "ID":"Idaho","IL":"Illinois","IN":"Indiana","KS":"Kansas","KY":"Kentucky",
        "LA":"Louisiana","MA":"Massachusetts","MD":"Maryland","ME":"Maine","MI":"Michigan",
        "MN":"Minnesota","MO":"Missouri","MS":"Mississippi","MT":"Montana",
        "NC":"North Carolina","ND":"North Dakota","NE":"Nebraska","NH":"New Hampshire",
        "NJ":"New Jersey","NM":"New Mexico","NV":"Nevada","NY":"New York",
        "OH":"Ohio","OK":"Oklahoma","OR":"Oregon","PA":"Pennsylvania",
        "RI":"Rhode Island","SC":"South Carolina","SD":"South Dakota",
        "TN":"Tennessee","TX":"Texas","UT":"Utah","VA":"Virginia","VT":"Vermont",
        "WA":"Washington","WI":"Wisconsin","WV":"West Virginia","WY":"Wyoming"
    };

    var getStateFullName = function(abbr) {
        return STATE_NAME_MAP[abbr.toUpperCase()];
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
                    data['locationType'] = geocodeResult['type'];
                    data['normalizedAddress'] = geocodeResult['normalizedAddress'];
//                    data['totalResults'] = geocodeResult['totalResults'];
                    data['city'] = geocodeResult['city'];
                    data['county'] = geocodeResult['county'];
                    data['sortBy'] = 'DISTANCE';
                  console.log(data);
                  console.log(data['county']);
                    (geocodeCallbackFn || defaultGeocodeCallbackFn)(data);
                } else {
                    if (GS.search.stateAbbreviation && getStateFullName(GS.search.stateAbbreviation)) {
                        alert("Location not found in " + getStateFullName(GS.search.stateAbbreviation) + ". Please enter a valid address, city, or ZIP.");
                    } else {
                        alert("Location not found. Please enter a valid address, city, or ZIP.");
                    }
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
            var geocodeOptions = { 'address': searchInput};
            if (GS.search.stateAbbreviation != null) {
                geocodeOptions['componentRestrictions'] = {'administrativeArea':  GS.search.stateAbbreviation.toUpperCase()};
            } else {
                geocodeOptions['componentRestrictions'] = {'country':  'US'};
            }
            geocoder.geocode(geocodeOptions, function (results, status) {
                var GS_geocodeResults = new Array();
                if (status == google.maps.GeocoderStatus.OK && results.length > 0) {
                    for (var x = 0; x < results.length; x++) {
                        var geocodeResult = new Array();
                        geocodeResult['lat'] = results[x].geometry.location.lat().toFixed(7);
                        geocodeResult['lon'] = results[x].geometry.location.lng().toFixed(7);
                        geocodeResult['normalizedAddress'] = formatNormalizedAddress(results[x].formatted_address).substring(0, 75);
                        geocodeResult['type'] = results[x].types.join().substring(0, 50);
                        if (results[x].partial_match) {
                            geocodeResult['partial_match'] = true;
                        } else {
                            geocodeResult['partial_match'] = false;
                        }
                        for (var i = 0; i < results[x].address_components.length; i++) {
                            if (results[x].address_components[i].types.contains('administrative_area_level_1')) {
                                geocodeResult['state'] = results[x].address_components[i].short_name.substring(0, 30);
                            }
                            if (results[x].address_components[i].types.contains('administrative_area_level_2')) {
                              geocodeResult['county'] = results[x].address_components[i].short_name.substring(0, 30);
                            }
                            if (results[x].address_components[i].types.contains('country')) {
                                geocodeResult['country'] = results[x].address_components[i].short_name.substring(0, 20);
                            }
                            if (results[x].address_components[i].types.contains('postal_code')) {
                                geocodeResult['zipCode'] = results[x].address_components[i].short_name.substring(0, 15);
                            }
                            if (results[x].address_components[i].types.contains('locality')) {
                                geocodeResult['city'] = results[x].address_components[i].long_name.substring(0, 50);
                            }
                        }
                        // http://stackoverflow.com/questions/1098040/checking-if-an-associative-array-key-exists-in-javascript
                        if (!('lat' in geocodeResult && 'lon' in geocodeResult &&
                            'state' in geocodeResult &&
                            'normalizedAddress' in geocodeResult &&
                            'country' in geocodeResult)||
                            geocodeResult['country'] != 'US') {
                            geocodeResult = null;
                        } else if ('type' in geocodeResult && geocodeResult['type'].indexOf('administrative_area_level_1') > -1) {
                            geocodeResult = null; // don't allow states to be returned
                        } else if (GS.search.stateAbbreviation != null && geocodeResult['state'].toUpperCase() != GS.search.stateAbbreviation.toUpperCase()) {
                            geocodeResult = null; // don't allow results outside of state
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
        var externalSearch = (document.referrer &&
            (document.referrer.indexOf('search/search.page') == -1 && document.referrer.indexOf('/schools/') == -1));
        if(externalSearch || $.cookie('showFiltersMenu') == 'true' || $.cookie('showFiltersMenu') == undefined){
            if ($(document).width() > GS.window.sizing.maxMobileWidth && searchResultsDisplayed() ) {
                $('.js-searchFiltersMenu').show();
            }
        }
        $.cookie('showFiltersMenu', 'false', {path:'/'});
    };

    var updateFilterState = function() {
        var queryData = GS.uri.Uri.getQueryData();
        if (queryData) {
            var $form = $('form.js-searchFiltersForm');
            for (var filterName in queryData) {
                if (queryData.hasOwnProperty(filterName)){
                    var inputName = normalizeInputName(filterName);
                    var filterValue = queryData[filterName];
                    try {
                        if (typeof filterValue === 'object' && filterValue.length) {
                            for (var x=filterValue.length-1; x >= 0; x--) {
                                // currently, filters with multi-values can't be represented by selects
                                updateFormElement($form, inputName, filterValue[x], {includeSelect:false});
                            }
                        } else {
                            updateFormElement($form, inputName, filterValue, {includeSelect:true});
                        }
                    } catch (e) {
                        // continue
                    }
                }
            }
            // update parent elements who have had children modified (i.e. sports gender icon and check box groups)
            GS.forms.toggleCheckboxForCollapsibleBoxOnLoad();
            GS.forms.toggleButtonForSportsOnLoad();
        }
    };

    // Remove [] (which is optional) to simplify later selectors
    var normalizeInputName = function(inputName) {
        inputName = inputName.replace('%5B%5D', '');
        inputName = inputName.replace('[]', '');
        return inputName;
    };

    var updateFormElement = function($form, name, value, options) {
        if (options && options['includeSelect']) {
            var $aSelect = $form.find('select[name="' + name + '"]');
            if ($aSelect.length > 0) {
                $aSelect.val(value);
                if ($aSelect.val() === null) {
                    $aSelect.val(''); // return to default value if value is unknown
                }
                return true; // found something to update so exit early
            }
        }
        // ^= means startsWith
        $form.find('.js-gs-checkbox-search[data-gs-checkbox-name^="' + name + '"]').
            filter('[data-gs-checkbox-value="' + value + '"]').
            each(GS.forms.checkFancyCheckbox);
        $form.find('.js-sportsIconButton[data-gs-checkbox-category^="' + name + '"]').
            filter('[data-gs-checkbox-value="' + value + '"]').
            each(GS.forms.checkSportsIcon);
    };

    var searchResultsDisplayed = function() {
        return $('.js-numOfSchoolsFound').data('numOfSchoolsFound') > 0
    };

    var setShowFiltersCookieHandler = function() {
        GS.search.setShowFiltersCookieHandler('.js-browseSchools'); //state hub browse city links
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

    var placeholderMobile = function () {
        if ($(window).width() < 481) {
            $('.js-mobile-placeholder').html('City, zip, address or school');
        }
        else {
            $('.js-mobile-placeholder').html('Enter city, zip code, address or school name');
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
        placeholderMobile: placeholderMobile,
        checkGooglePlaceholderTranslate: checkGooglePlaceholderTranslate,
        setShowFiltersCookieHandler: setShowFiltersCookieHandler,
        updateFilterState: updateFilterState
    };
})();
