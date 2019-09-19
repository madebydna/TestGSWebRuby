import {
  getPath, removeFromQueryString, putParamObjectIntoQueryString, goToPage,
  addHiddenFieldsToForm, getQueryStringFromObject, getQueryData
} from '../../util/uri';
import { preserveLanguageParam } from '../../util/i18n';

Array.prototype.contains = function(obj) {
  var i = this.length;
  while (i--) {
    if (this[i] === obj) {
      return true;
    }
  }
  return false;
};

let stateAbbreviation;
let searchType = 'byName';
let findByNameSelector = 'input#js-findByNameBox';
let findByLocationSelector = 'input#js-findByLocationBox';
let schoolResultsSearchSelector = "input[name='locationSearchString']";

if (typeof(gon) !== 'undefined' ) {
  stateAbbreviation = gon.state_abbr;
}

const SEARCH_PAGE_PATH = '/search/search.page';
const locationSelector = '.search-type-toggle div:first-child';
const nameSelector = '.search-type-toggle div:last-child';
const mobileShortPlaceholder = 'City, zip, address or school';
const mobileLongPlaceholder = 'Find a great school';

const init = function() {
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
      searchType = 'byLocation';
    }
    else{
      isAddress(input.value);
    }

    // PT-903. We are now loading Google Maps API asynchronously.
    // If it does not come back by the time someone searches:
    // we wait 200ms, look again, and default to byName search if it still has not loaded.
    // byName searches require a state, so we default to California if there is no state.
    if (typeof google === 'undefined' || typeof google.maps === 'undefined') {
      setTimeout( function() {
        if (typeof google === 'undefined' || typeof google.maps === 'undefined') {
          searchType = 'byName';
          stateAbbreviation = stateAbbreviation || 'ca';
        }
      }, 200);
    }

    if (valid) {
      var searchOptions = {};

      if (input.value == $(schoolResultsSearchSelector).data('prev-search') && stateAbbreviation == $(schoolResultsSearchSelector).data('state')) {
        var params = removeFromQueryString(window.location.search, 'page');
        params = putParamObjectIntoQueryString(params, searchOptions);
        var url = window.location.protocol + '//' + window.location.host + getPath() + params;
        url = preserveLanguageParam(url);
        goToPage(url);
        return false
      } else if (searchType == 'byLocation') {
        findByLocationSelector = schoolResultsSearchSelector;
        return submitByLocationSearch.apply(this);
      } else if (searchType == 'byName') {
        findByNameSelector = schoolResultsSearchSelector;
        addHiddenFieldsToForm({state: stateAbbreviation}, this);
        return submitByNameSearch.call(this, searchOptions);
      } else {
        return false;
      }
    } else {
      return false;
    }
  });
  setUpCollapsibleTitle();

  closeFilters();
};

const setupTabs = function() {
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

const validateField = function(field, valueToIgnore) {
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

const STATE_NAME_MAP = {
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

const getStateFullName = function(abbr) {
  return STATE_NAME_MAP[abbr.toUpperCase()];
};

const isTermState = function(term) {
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

const submitByLocationSearch = function(geocodeCallbackFn) {
  var self = this;
  var searchQuery = getSearchQuery(self);
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
          data['sortBy'] = 'DISTANCE';
          (geocodeCallbackFn || defaultGeocodeCallbackFn)(data, searchQuery);
        } else {
          if (stateAbbreviation && getStateFullName(stateAbbreviation)) {
            alert("Location not found in " + getStateFullName(stateAbbreviation) + ". Please enter a valid address, city, or ZIP.");
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

const getSearchQuery = function(self) {
  var searchQuery = $(self).find(findByLocationSelector).val();
  return searchQuery.replace(/^\s*/, "").replace(/\s*$/, "");
};

const defaultGeocodeCallbackFn = function(geocodeResult, searchQuery) {
  var searchOptions = jQuery.extend({}, geocodeResult);
  for (var urlParam in searchOptions) {
    if (searchOptions.hasOwnProperty(urlParam)) {
      searchOptions[urlParam] = encodeURIComponent(searchOptions[urlParam]);
    }
  }
  searchOptions['locationSearchString'] = encodeURIComponent(searchQuery);
  searchOptions['distance'] = $('#js-distance-select-box').val() || 5;

  // Not setting a timeout breaks back button
  setTimeout(function() { 
    var url = window.location.protocol + '//' + window.location.host +
      SEARCH_PAGE_PATH + getQueryStringFromObject(searchOptions);
    url = preserveLanguageParam(url);
    goToPage(url); 
  }, 1);
};


const isAddress = function (query) {
  var is_ad = false;

  is_ad = is_ad || matchesAddress(query);
  is_ad = is_ad || matchesFiveDigits(query);
  is_ad = is_ad || matchesFiveDigitsPlusFourDigits(query);

  searchType = is_ad ? 'byLocation' : 'byName';
  return is_ad
};

//Matches only 5 digits
//Todo currently 3-4 schools would match this regex, but it may not be worth maintain a list of those schools to prevent matches
const matchesFiveDigits = function (query) {
  return /(\D|^)\d{5}(\D*$|$)/.test(query)
};

//Matches 5 digits + dash or space or no space + 4 digits.
const matchesFiveDigitsPlusFourDigits = function (query) {
  return /(\D|^)\d{5}(-|\s*)\d{4}(\D|$)/.test(query);
};

//Matches when first character/characters are numbers + a space + if it does not match schools in the school and district list.
//ToDo perhaps not worth maintaining list of 300 schools for this regex.
//ToDo if we do decide to maintain the list, perhaps move this into a service that autogenerates the list
const matchesAddress = function(query) {
  //        return (matchesNumbersAsOnlyFirstCharacters(query) && !matchesSchoolsList(query) && !matchesDistrictsList(query))
  return matchesNumbersAsOnlyFirstCharacters(query) || matchesStateAbbreviationQuery(query);
};

const matchesNumbersAsOnlyFirstCharacters = function(query) {
  return /^\W*\d+\s/.test(query);
};

const matchesStateAbbreviationQuery = function(query) {
  return /\w*, \w\w\b/.test(query);
};

//there are about 300 schools that will accidentally generate a false positive on the address detection regex
//if we want to support not matching on these schools then we will need to generate a list of these schools for the regex to check
const matchesSchoolsList = function(query) {
  return new RegExp(query, 'i').test(schoolsList);
};

//there are about 3 districts that will accidentally generate a false positive on the address detection regex
//if we want to support not matching on these districts then we will need to add this check to the mattches address regex above
const matchesDistrictsList = function(query) {
  return new RegExp(query, 'i').test(districtsList);
};

const getSchoolsList = function() {
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

const schoolsList = getSchoolsList();

const getDistrictsList = function() {
  var districts = [
    '302 - K12 FLORIDA, LLC',
    '301 - FLORIDA CONNECTIONS',
    '100 Legacy Academy Charter School'
  ];
  return districts.join("|");
};

const districtsList = getDistrictsList();

const formatNormalizedAddress = function(address) {
  var newAddress = address.replace(", USA", "");
  var zipCodePattern = /(\d\d\d\d\d)-\d\d\d\d/;
  var matches = zipCodePattern.exec(newAddress);
  if (matches && matches.length > 1) {
    newAddress = newAddress.replace(zipCodePattern, matches[1]);
  }
  return newAddress;
};

const gsGeocode = function(searchInput, callbackFunction) {
  var geocoder = new google.maps.Geocoder();
  if (geocoder && searchInput) {
    var geocodeOptions = { 'address': searchInput};
    geocodeOptions['componentRestrictions'] = {'country':  'US'};
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
            } else if (stateAbbreviation != null && geocodeResult['state'].toUpperCase() != stateAbbreviation.toUpperCase()) {
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

const submitByNameSearch = function(queryStringOptions) {
  var searchString = $(this).find(findByNameSelector).val();
  //        TODO temporarily added find('[name=state]')
  var state = $(this).find('input#js-state').val() || $(this).find('[name=state]').val();
  var collectionId = $(this).find('input#js-collectionId').val();
  var queryString = jQuery.extend({}, queryStringOptions);

  queryString.q = encodeURIComponent(searchString);
  if (typeof collectionId !== 'undefined') {
    queryString.collectionId = collectionId;
  }
  if (typeof state !== 'undefined' && state !== '') {
    queryString.state = state;
  }

  setTimeout(function() {
    var url = window.location.protocol + '//' + window.location.host +
      SEARCH_PAGE_PATH + getQueryStringFromObject(queryString);
    url = preserveLanguageParam(url);
    goToPage(url);
  }, 1);
  return false;
};

const setUpCollapsibleTitle = function() {
  $('.js-slideToggle').on('click', function(e) {
    var target = $(this).data('target');
    if (target) {
      var $caret = $(this).children('.caret');
      var $target = $(target);
      $caret.toggleClass('caret-left');
      $($target).slideToggle();
    }
  });
};

const updateFilterState = function() {
  var updated = false;
  var queryData = getQueryData();
  var filterName;
  if (queryData) {
    var $form = $('form.js-searchFiltersForm');
    for (filterName in queryData) {
      if (queryData.hasOwnProperty(filterName)){
        updated = true;
        updateSingleFilterState($form, filterName, queryData[filterName]);
      }
    }
  }
  // in case the server applied a filter that isn't in the URL, or the server modified a filter value
  // make sure the form value reflects that
  // e.g. if distance=0 in URL, server may choose to apply distance=1
  if (window.gon && gon.search_applied_filter_values) {
    for (filterName in gon.search_applied_filter_values) {
      if (gon.search_applied_filter_values.hasOwnProperty(filterName)){
        updated = true;
        updateSingleFilterState($form, filterName, gon.search_applied_filter_values[filterName]);
      }
    }
  }
  if (updated) {
    // update parent elements who have had children modified (i.e. sports gender icon and check box groups)
    GS.forms.toggleCheckboxForCollapsibleBoxOnLoad();
  }
};

const updateSingleFilterState = function($form, name, value) {
  var inputName = normalizeInputName(name);
  var filterValue = value;
  try {
    if (typeof filterValue === 'object' && filterValue.length) {
      for (var x=filterValue.length-1; x >= 0; x--) {
        // currently, filters with multi-values can't be represented by selects
        updateFormElement($form, inputName, decodeURIComponent(filterValue[x]), {includeSelect:false});
      }
    } else {
      updateFormElement($form, inputName, decodeURIComponent(filterValue), {includeSelect:true});
    }
  } catch (e) {
    // continue
  }
};

// Remove [] (which is optional) to simplify later selectors
const normalizeInputName = function(inputName) {
  inputName = inputName.replace('%5B%5D', '');
  inputName = inputName.replace('[]', '');
  return inputName;
};

const updateFormElement = function($form, name, value, options) {
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

const searchResultsDisplayed = function() {
  return $('.js-numOfSchoolsFound').data('numOfSchoolsFound') > 0
};

const setShowFiltersCookieHandler = function() {
  GS.search.setShowFiltersCookieHandler('.js-browseSchools'); //state hub browse city links
};

const closeFilters = function () {
  $('.js-close').click(function () {
    $(this).parent().fadeOut('fast');
  });
}

const setupToolTip = function() {
  $('.js-open-tooltip').tooltip('show');
};

export {
  init,
  setupTabs,
  submitByLocationSearch,
  submitByNameSearch,
  getSearchQuery,
  gsGeocode,
  isAddress,
  searchType,
  findByNameSelector,
  findByLocationSelector,
  setShowFiltersCookieHandler,
  updateFilterState,
  setupToolTip,
  closeFilters
};
