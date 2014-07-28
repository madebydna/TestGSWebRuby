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
    var prototypeSearchSelector = 'input#js-prototypeSearch';
    var locationSelector = '.search-type-toggle div:first-child';
    var nameSelector = '.search-type-toggle div:last-child';
    var searchType = 'byName';

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

        $('.js-prototypeSearchForm').submit(function() {
            var valid = validateField($(this).find(prototypeSearchSelector)[0]);
            var searchType = GS.search.schoolSearchForm.searchType;
            if (valid) {
                if (searchType == 'byLocation') {
                    findByLocationSelector = prototypeSearchSelector;
                    return submitByLocationSearch.apply(this);
                } else if (searchType == 'byName') {
                    findByNameSelector = prototypeSearchSelector;
//                    ToDo Hard coded byName search to Delaware
                    GS.uri.Uri.addHiddenFieldsToForm({state: 'DE'}, this)
                    return submitByNameSearch.apply(this);
                } else {
                    return false;
                }
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

    var autocompleteSort = function(obj1, obj2) {
        if (obj1.sort_order > obj2.sort_order)
            return -1;
        if (obj1.sort_order < obj2.sort_order)
            return 1;
        return 0;
    };

    var submitByLocationSearch = function(geocodeCallbackFn) {
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
        var searchQuery = $(findByLocationSelector).val();
        return searchQuery.replace(/^\s*/, "").replace(/\s*$/, "");
    };

    var defaultGeocodeCallbackFn = function(geocodeResult) {
        var searchOptions = jQuery.extend({}, geocodeResult);
        searchOptions['locationSearchString'] = getSearchQuery();
        searchOptions['distance'] = $('#js-distance-select-box').val() || 5;
        var gradeLevelFilter = $('#js-prototypeSearchGradeLevelFilter');
        if (gradeLevelFilter.length > 0 && gradeLevelFilter.val() != '') {
            searchOptions['grades'] = gradeLevelFilter.val();
        }

        // Not setting a timeout breaks back button
        setTimeout(function() { window.location.href = window.location.protocol + '//' + window.location.host +
            SEARCH_PAGE_PATH +
            GS.uri.Uri.getQueryStringFromObject(searchOptions); }, 1);
    };

    var schools = new Bloodhound({
        datumTokenizer: Bloodhound.tokenizers.obj.whitespace('school_name'),
        queryTokenizer: Bloodhound.tokenizers.whitespace,
        limit:4,
        dupDetector: function(remoteMatch, localMatch) {
            return remoteMatch.url == localMatch.url;
        },
        sorter: autocompleteSort,
        remote: {
            url: '/gsr/search/suggest/school?query=%QUERY&state=Delaware',
            filter: function(data) {
                schools = $(GS.search.schoolSearchForm.schools)[0];
                cacheList = schools.cacheList;
                for (var i = 0; i < data.length; i++) {
                    if (cacheList[data[i].url] == null) {
                        schools.add(data[i]);
                        cacheList[data[i].url] = true;
                    }
                }
                return data.sort(autocompleteSort);
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
        sorter: autocompleteSort,
        remote: {
            url: '/gsr/search/suggest/city?query=%QUERY&state=Delaware',
            filter: function(data) {
                cities = $(GS.search.schoolSearchForm.cities)[0];
                cacheList = cities.cacheList;
                for (var i = 0; i < data.length; i++) {
                    if (cacheList[data[i].url] == null) {
                        cities.add(data[i]);
                        cacheList[data[i].url] = true;
                    }
                }
                return data.sort(autocompleteSort);
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
        sorter: autocompleteSort,
        remote: {
            url: '/gsr/search/suggest/district?query=%QUERY&state=Delaware',
            filter: function(data) {
                districts = $(GS.search.schoolSearchForm.districts)[0];
                cacheList = districts.cacheList;
                for (var i = 0; i < data.length; i++) {
                    if (cacheList[data[i].url] == null) {
                        districts.add(data[i]);
                        cacheList[data[i].url] = true;
                    }
                }
                return data.sort(autocompleteSort);
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
                suggestion: Handlebars.compile('<a href="{{url}}" style="text-decoration:none; color: #000000"><p><span style="color:grey; font-style: italic">Schools in</span> <strong style="font-weight: 900;">{{city_name}}, DE</strong></p></a>')
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
                suggestion: Handlebars.compile('<a href="{{url}}" style="text-decoration:none; color: #000000"><p><span style="color:grey; font-style: italic">Schools in</span> <strong style="font-weight: 900;">{{district_name}}, DE</strong></p></a>')
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
                suggestion: Handlebars.compile('<a href="{{url}}" style="text-decoration:none; color: #000000"><p><strong style="font-weight: 900;">{{school_name}}</strong></br><span style="color:grey">- {{city_name}}, DE</span></p></a>')
            }
        })
        .on('typeahead:selected', function(event, suggestion, dataset) {
            GS.uri.Uri.goToPage(suggestion['url']);
        })
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
        return (matchesNumbersAsOnlyFirstCharacters(query) && !matchesSchoolsList(query) && !matchesDistrictsList(query))
    };

    var matchesNumbersAsOnlyFirstCharacters = function(query) {
        return /^\W*\d+\s/.test(query);
    };

    var matchesSchoolsList = function(query) {
        return new RegExp(query, 'i').test(schoolsList);
    };

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
            '101 Elementary School',
            '123 Learning Center',
            '4 C\'s-William K Johnson Infant',
            '5 Talents Childrens Academy',
            '123 Pre-School',
            '24 Hour Optcc',
            '24 Hour Day Children Center',
            '3 N 1 Pre-School',
            '4 C\'s',
            '100 Black Men Of The Bay Area Community',
            '180 Program',
            '70 ONLINE',
            '70 Online',
            '1 2 3 Grow With Me',
            '4 C Head Start-Palm Plz',
            '7 Star Learning Center',
            '301 - FLORIDA CONNECTIONS',
            '302 - K12 FLORIDA, LLC',
            '123 Grow With Me Learning Center',
            '4 C Head Start Baker St',
            '2016 Fessenden Head Start',
            '3002 Cross City Head Start',
            '1007 Abc Children\'s Head Start',
            '4 C Early Childhood Development Center',
            '4 Ever Learning Academy',
            '8.5 Alternative Program',
            '101 Kid\'s Place Day Care',
            '1 Priority Learning Academy',
            '5 Star Child Care & Learning Center',
            '100 Acre Woods Child Care Center',
            '4 G\'s Child Care',
            '123 You N Me Preschool',
            '4 Kids Child Care',
            '8 Points Charter School',
            '123 & Abc Academy',
            '2450 Childcare Inc Dba Happy Days Childc',
            '714 Head Start',
            '15 Th St Head Start',
            '2 Friends Day Care',
            '3 Sisters & The Mom Day Care',
            '24 Hours To Go Day Care 2',
            '3 Steps Day Care',
            '123 Grow Child Center',
            '123 Grow Child Center',
            '123 Grow Child Center',
            '7 Seas-Cape Cod Community Clge DC',
            '7 Seas Child Care-Cape Cod',
            '123 Grow Child Center',
            '1 Lt Charles W. Whitcomb School',
            '123 Grow Child Center',
            '5 Senses Child Care Center',
            '100 Acre Wood Day Care',
            '123 Kidz St Child Care Center',
            '19 & Schoenherr Kindercare',
            '2 Day\'S Child Learning Center',
            '2 Sweets Angels Family Daycare',
            '24 Hours Kare For Kids Dc',
            '281 Highview Alternative Program',
            '276 Minnetonka Compass',
            '281 Winnetka Learning Center Alc',
            '271 Shape ALC',
            '281 Forest Elementary TS',
            '270 Hopkins Alternative',
            '271 Beacon Night School',
            '281 Meadow Lake El TS',
            '281 Neill El TS',
            '281 Northport El TS',
            '281 Sandburg Middle TS',
            '270 Hopkins Is',
            '281 Robbinsdale Tasc Alc',
            '270 Alice Smith Elementary TS',
            '279 Crest View TS',
            '281 Lake View El TS',
            '273 Concord El TS',
            '917 Transitional Education Serv Alt',
            '917 So. St. Paul Junior/Senior High School',
            '917 Intra-Dakota Educational Alt',
            '917 D/Hoh Gideon Pond Elementary',
            '917 Paces',
            '917 Farmington High School',
            '917 Lakeville North High School',
            '917 Hastings High School',
            '917 Pine Bend Elementary School',
            '917 Crista McAuliffe Elementary School',
            '917 Hastings Middle School',
            '917 Nicollet Junior High School',
            '917 Sibley High School',
            '917 McQuire Junior High School',
            '622 Alternative Middle/High School',
            '279 Osseo Is Alc',
            '279 Osseo Jr High Alc',
            '279 Osseo Sr Hi Alc',
            '270 Hopkins West Jr High Alc',
            '270 Hopkins North Jr High Alc',
            '276 Minnetonka High School Is',
            '280 Centennial Elementary TS',
            '280 Richfield Middle School TS',
            '271 Olson Middle School I Power ALC',
            '622 Targeted Services',
            '270 Tanglen Elementary - TS',
            '271 Mindquest Oll',
            '270 Hopkins Alt. Prg - Off Campus',
            '276 Minnetonka RSR-ALC',
            '917 Simley High School Special Ed.',
            '281 Pilgrim Lane El TS',
            '281 Plymouth Middle TS',
            '271 Pond El TS',
            '281 Sonnesyn El TS',
            '281 Sunny Hollow El TS',
            '279 Weaver Lake El TS',
            '279 Garden City El TS',
            '279 Birch Grove Elementary School TS.',
            '279 Park Brook Elementary TS',
            '270 Kathrine Curren El TS.',
            '271 Normandale Hills Elementary School TS.',
            '271 Poplar Bridge El TS.',
            '271 Westwood Elementary School TS.',
            '271 Indian Mounds Elementary School TS.',
            '271 Oak Grove Int. TS.',
            '279 Fair Oaks Elementary School TS.',
            '279 Orchard Lane El. TS.',
            '283 Aquila Learning Center TS.',
            '283 Cedar Manor TS',
            '283 Peter Hobard Elementary School TS.',
            '283 St. Louis Park Learning Center TS.',
            '283 Susan Lindgren TS.',
            '271 Oak Grove Elementary School TS.',
            '271 Valley View El TS.',
            '271 Olson Elementary School TS.',
            '270 Hopkins YES ALC',
            '279 Elm Creek El TS',
            '271 Washburn El TS',
            '271 Ridgeview El TS',
            '271 Olson Middle TS',
            '273 Cornelia El TS',
            '273 Countryside El TS',
            '273 Creek Valley El TS',
            '273 Highlands El TS',
            '273 Normandale El TS',
            '273 So View Middle TS',
            '273 Valley View Middle TS',
            '273 Edina Public TS',
            '281 Armstrong Learning Lab Alc',
            '281 Cooper High School Abc Alc',
            '287 Alc Part Time',
            '283 Perspective SLP TS',
            '270 Gatewood Elementary TS',
            '270 Eisenhower Elementary TS',
            '281 Hosterman Middle TS',
            '281 Robbinsdale Wings ALC',
            '277 Westonka ALC',
            '281 Winnetka Learning Center Is',
            '270 Hopkins West Junior High TS',
            '279 Edinbrook Elementary TS',
            '279 Willow Lane El. TS.',
            '270 Hopkins North Junior High TS',
            '280 Sheridan Hills Elementary TS',
            '280 Richfield Int Elementary TS',
            '281 Zachary Lane TS',
            '281 Noble Elementary TS',
            '281 Middle School Connections ALC',
            '281 Plymouth Youth TC',
            '271 Hillcrest Elementary TS',
            '281 New Hope Elementary TS',
            '271 Valley View Middle TS',
            '279 Zanewood Elementary TS',
            '286 Brooklyn Center TS',
            '283 Park Spanish Immersion TS',
            '272 Central Middle School Alt',
            '270 Meadowbrook Elementary - TS',
            '271 Kennedy HS. Beacon Night School',
            '281 Robbinsdale (Tasc) Mid Alc',
            '272 Central Mid School TS',
            '272 Cedar Ridge El TS',
            '272 Eden Lake El TS',
            '272 Forest Hills El TS',
            '272 Oak Point Int TS',
            '272 Prairie View El TS',
            '270 Hopkins High School Is Alc',
            '287 Oll Academic',
            '287 On-Line Learning (Sped)',
            '287 Alc Combined Is',
            '917 Burnsville High School',
            '917 Farmington Middle School East',
            '917 Century Junior High School',
            '279 Osseo Area Learning Center Ey',
            '270 Hopkins 4 Week Ey',
            '270 Hopkins 6 Week Ey',
            '287 Lincoln Hills Middle School ALC',
            '283 St Louis Pk Independent Study',
            '271 - Shape - Intermediate School',
            '271 - District Extended Year',
            '277 - Grandview Middle School -TS',
            '277 - Hilltop Elementary - TS',
            '277 - Mound Westonka - TS',
            '277 - Shirley Hills Elementary -TS',
            '277 Westonka Area Learning Academy',
            '279 - Palmer Lake Elementary - TS',
            '281 Highview High School - Is',
            '286 - Earle Brown Elementary - TS',
            '535 Online Campus',
            '196 Extended School Year',
            '917 Sun',
            '283 District Summer Programs - TS',
            '283 Meadowbrook Elementary - TS',
            '917 Dash',
            '276 Minnetonka Compass Ext Yr',
            '279 - Osseo Junior High School - TS',
            '279 Garden City Elementary - Ey - TS',
            '272 Eagle Heights Spanish Immersion-TS',
            '917 Middle Level Alc',
            '917 Targeted Services',
            '112 ALC MIDDLE SCHOOL',
            '4126 - Prairie Seeds Academy - Is',
            '271 Shape Is',
            '1050 Adair Co. High',
            '417 Early Learning Center',
            '2 By 2 Pre-School & Day Care',
            '40 Mile Colony',
            '3 R\'s Pre-School',
            '4 Point 0: Student-Centered Learning Solutions',
            '5 GS Learning Center',
            '1 2 3 Grow Child Care',
            '100 R Elementary School',
            '81 R Elementary School',
            '2304 Golden Hills Head Start',
            '2302 Head Start',
            '4 Views Academy 2',
            '100 Acre Wood Day Care',
            '100 Legacy Academy Charter School',
            '24 Hour Fitness Kid\'s Club Dc',
            '24 Hour Fitness Kid\'s Club Dc',
            '24 Hour Fitness Kid\'s Club Dc',
            '24 Hour Fitness Kid\'s Club Dc',
            '24 Hour Fitness Kid\'s Club Dc',
            '24 Hour Fitness Kid\'s Club Dc',
            '2 Bee Busy Learning Center',
            '1 School',
            '2 School',
            '4 School',
            '5 School',
            '6 School',
            '196 Albany Ave Dcc',
            '200 Central Ave Day Care Center',
            '4 Angels Day Care',
            '1485 Center Head Start',
            '214 Stuyvesant Head Start',
            '123 Play Pre-School',
            '133 Head Start',
            '971 Head Start',
            '262 Head Start',
            '121 Montague St Child Care Center',
            '12 Little Piggies Day Care',
            '4 Seasons',
            '4 The Luv Of Children Child Care Center',
            '4 Little Ones Learning Center',
            '123 All About Me 1 Day Care',
            '123 All About Me 2 Day Care',
            '4 Kidz Christian Academy',
            '4 Your Child Care Center I',
            '4 Your Child Care Center Ii',
            '4 Kids Cccr-Mckeesport',
            '10 Th & Exeter Center Head Start',
            '4 Your Child Care Center Iii',
            '123 Back To Basics Day Care I',
            '123 Back To Basics Day Care Ii',
            '3 Steps Learning Center',
            '1 Plus 1 Is 2 Day Care',
            '96 Junction Day Care',
            '2 Steps Ahead Learning Center',
            '3 D Day Care',
            '123 Learning Academy',
            '24 Hour Care LLC',
            '2 Granny\'s House Inf & Child Care Center',
            '3 D Daycare',
            '3 D Academy Child Care Center',
            '100 Acre Woods Pre-School & Learning Center',
            '3 J\'s',
            '5 2 Child Learning Center',
            '1 2 Me Childcare Center',
            '803 Old Mcdonald Dc & Lc',
            '4 Our Kids Learning Academy',
            '1 2 Me Child Care',
            '24 Hour Fitness Center Dc-Provo',
            '24 Hour Fitness Dcc',
            '24 Hrs Kids Club',
            '5 Plus 2 Child Care Center',
            '123 Abc Little Learners Academy',
            '4 R\'s Pre-School',
            '4 Corners Children\'s Center',
            '5 Star Childcare Center',
            '4 Dakids Refugee/Immig Family Center',
            '21 For Tots Day Care',
            '2 Plus 2 Child Care Center',
            '1 2 3 Pre-School',
            '3 Creek Ranch Day Care',
            '5 Star Child Care Center'
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
//        TODO temporarily added find('[name=state]')
        var state = $(this).find('input#js-state').val() || $(this).find('[name=state]').val();
        var collectionId = $(this).find('input#js-collectionId').val();
        var searchType = $(this).find('input[name="search_type"]').val();
        var queryString = {};

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
        getSearchQuery: getSearchQuery,
        gsGeocode: gsGeocode,
        cities: cities,
        districts: districts,
        schools: schools,
        attachAutocomplete: attachAutocomplete,
        isAddress: isAddress,
        searchType: searchType
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
});
