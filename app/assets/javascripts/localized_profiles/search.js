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
GS.search.schoolSearchForm = GS.search.schoolSearchForm || (function() {
    var SEARCH_PAGE_PATH = '/search/search.page';
    var findByNameSelector = 'input#js-findByNameBox';
    var findByLocationSelector = 'input#js-findByLocationBox';
    var prototypeSearch = 'input#js-prototypeSearch';
    var locationSelector = '.search-type-toggle div:first-child';
    var nameSelector = '.search-type-toggle div:last-child';

    var init = function(state) {
        $('.js-findByLocationForm').submit(function() {
            var valid = validateField($(this).find(findByLocationSelector)[0]);
            if (valid) {
                return submitByLocationSearch.apply(this);
            } else {
                return false;
            }
        });

        $('.js-findByNameForm').submit(function() {
            var valid = validateField($(this).find(findByNameSelector)[0]);
            if (valid) {
                return submitByNameSearch.apply(this);
            } else {
                return false;
            }
        });

        $('.prototypeSearchForm').submit(function() {
            var valid = validateField($(this).find(prototypeSearch)[0]);
            if (valid) {
                return submitPrototypeSearch.apply(this);
            } else {
                return false;
            }
        });

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
    }

    var validateField = function(field) {
        if (field['value'] == field['defaultValue']) {
            return false;
        }

        if (field['value'].length == 0) {
            return false;
        }

        if (/^\s+$/.test(field['value'])) {
            return false;
        }

        return true;
    }

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

                    // Not setting a timeout breaks back button
                    setTimeout(function() { window.location.href = window.location.protocol + '//' + window.location.host +
                            SEARCH_PAGE_PATH +
                            GS.uri.Uri.getQueryStringFromObject(data); }, 1);
                } else {
                    alert("Location not found. Please enter a valid address, city, or ZIP.");
                }
            });
        } else {
            alert("Please enter an address, zip code or city and state");
        }

        return false;
    };

    var schools = new Bloodhound({
        datumTokenizer: Bloodhound.tokenizers.obj.whitespace('school_name'),
        queryTokenizer: Bloodhound.tokenizers.whitespace,
        limit:4,
        dupDetector: function(remoteMatch, localMatch) {
            return remoteMatch.url == localMatch.url;
        },
        sorter: function(school1, school2) {
            if (school1.sort_order > school2.sort_order)
                return -1;
            if (school1['sort_order'] < school2['sort_order'])
                return 1;
            return 0;
        },
        remote: {
            url: '/search/suggest/school?query=%QUERY&state=California',
            filter: function(data) {
                schools = $(GS.search.schoolSearchForm.schools)[0];
                cacheList = schools.cacheList;
                for (var i = 0; i < data.length; i++) {
                    if (cacheList[data[i].url] == null) {
                        schools.add(data[i]);
                        cacheList[data[i].url] = true;
                    }
                }
                return data;
            },
            rateLimitWait: 100
        }
    });

    var cities = new Bloodhound({
        datumTokenizer: Bloodhound.tokenizers.obj.whitespace('city_name'),
        queryTokenizer: Bloodhound.tokenizers.whitespace,
        limit: 2,
        dupDetector: function(remoteMatch, localMatch) {
            return remoteMatch.url == localMatch.url;
        },
        sorter: function(city1, city2) {
            if (city1.sort_order > city2.sort_order)
                return -1;
            if (city1['sort_order'] < city2['sort_order'])
                return 1;
            return 0;
        },
        remote: {
            url: '/search/suggest/city?query=%QUERY&state=California',
            filter: function(data) {
                cities = $(GS.search.schoolSearchForm.cities)[0];
                cacheList = cities.cacheList;
                for (var i = 0; i < data.length; i++) {
                    if (cacheList[data[i].url] == null) {
                        cities.add(data[i]);
                        cacheList[data[i].url] = true;
                    }
                }
                return data;
            },
            rateLimitWait: 100
        }
    });

    var districts = new Bloodhound({
        datumTokenizer: Bloodhound.tokenizers.obj.whitespace('district_name'),
        queryTokenizer: Bloodhound.tokenizers.whitespace,
        limit:2,
        dupDetector: function(remoteMatch, localMatch) {
            return remoteMatch.url == localMatch.url;
        },
        sorter: function(district1, district2) {
            if (district1.sort_order > district2.sort_order)
                return -1;
            if (district1['sort_order'] < district2['sort_order'])
                return 1;
            return 0;
        },
        remote: {
            url: '/search/suggest/district?query=%QUERY&state=California',
            filter: function(data) {
                districts = $(GS.search.schoolSearchForm.districts)[0];
                cacheList = districts.cacheList;
                for (var i = 0; i < data.length; i++) {
                    if (cacheList[data[i].url] == null) {
                        districts.add(data[i]);
                        cacheList[data[i].url] = true;
                    }
                }
                return data;
            },
            rateLimitWait: 100
        }
    });

    var attachAutocomplete = function() {
        $('.typeahead').typeahead({
            hint: true,
            highlight: true,
            minLength: 1
        },
        {
            name: 'cities',
            displayKey: 'city_name',
            source: cities.ttAdapter(),

            templates: {
                header: '<h3 style="font-weight: bold;border-bottom: 1px solid #ccc;">Cities</h3>',
                empty: [
                    '<div class="empty-message" style="font-style:italic;">',
                    '(no results)',
                    '</div>'
                ].join('\n'),
                suggestion: Handlebars.compile('<a href="http://greatschools.org{{url}}" style="text-decoration:none; color: #000000"><p><span style="color:grey; font-style: italic">Schools in</span> <strong style="font-weight: 900;">{{city_name}}, DE</strong></p></a>')
            }
        },
        {
            name: 'districts',
            displayKey: 'district_name',
            source: districts.ttAdapter(),
            templates: {
                header: '<h3 style="font-weight: bold;border-bottom: 1px solid #ccc;">Districts</h3>',
                empty: [
                    '<div class="empty-message" style="font-style:italic;">',
                    '(no results)',
                    '</div>'
                ].join('\n'),
                suggestion: Handlebars.compile('<a href="http://greatschools.org{{url}}" style="text-decoration:none; color: #000000"><p><span style="color:grey; font-style: italic">Schools in</span> <strong style="font-weight: 900;">{{district_name}}, DE</strong></p></a>')
            }
        },
        {
            name: 'schools',
            displayKey: 'school_name',
            source: schools.ttAdapter(),
            templates: {
                header: '<h3 style="font-weight: bold;border-bottom: 1px solid #ccc;">Schools</h3>',
                empty: [
                    '<div class="empty-message" style="font-style:italic;">',
                    '(no results)',
                    '</div>'
                ].join('\n'),
                suggestion: Handlebars.compile('<a href="http://greatschools.org{{url}}" style="text-decoration:none; color: #000000"><p><strong style="font-weight: 900;">{{school_name}}</strong></br><span style="color:grey">- {{city_name}}, DE</span></p></a>')
            }
        })
    };

    var handleAddressOrZipcode = function() {
        $('#js-prototypeSearch').keyup(function() {
            var $input = $(this).val();
            if (/\d{5}/.test($input)) {
                $(this).data().ttTypeahead.minLength = 100;
                $(this).typeahead('close');
            } else {
                $(this).data().ttTypeahead.minLength = 1;
            }
        })
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

    var submitByNameSearch = function() {
        var searchString = $(this).find(findByNameSelector).val();
        var state = $(this).find('input#js-state').val();
        var collectionId = $(this).find('input#js-collectionId').val();
        var searchType = $(this).find('input[name="search_type"]').val();
        var queryString = GS.uri.Uri.getQueryData();

        queryString.q = encodeURIComponent(searchString);
        queryString.search_type = encodeURIComponent(searchType);
        if (typeof collectionId !== 'undefined') {
            queryString.collectionId = encodeURIComponent(collectionId);
        }
        queryString.state = encodeURIComponent(state);

        setTimeout(function() { window.location = window.location.protocol + '//' + window.location.host +
                SEARCH_PAGE_PATH +
                GS.uri.Uri.getQueryStringFromObject(queryString); }, 1);
    };

    return {
        init:init,
        setupTabs: setupTabs,
        submitByLocationSearch: submitByLocationSearch,
        submitByNameSearch: submitByNameSearch,
        gsGeocode: gsGeocode,
        cities: cities,
        districts: districts,
        schools: schools,
        attachAutocomplete: attachAutocomplete,
        handleAddressOrZipcode: handleAddressOrZipcode
    };
})();

$(document).ready(function() {
  GS.search.schoolSearchForm.init();
  GS.search.schoolSearchForm.setupTabs();
  GS.search.schoolSearchForm.cities.initialize();
  GS.search.schoolSearchForm.cities.cacheList = {};
  GS.search.schoolSearchForm.districts.initialize();
  GS.search.schoolSearchForm.districts.cacheList = {};
  GS.search.schoolSearchForm.schools.initialize();
  GS.search.schoolSearchForm.schools.cacheList = {};
  GS.search.schoolSearchForm.attachAutocomplete();
  GS.search.schoolSearchForm.handleAddressOrZipcode();
});
