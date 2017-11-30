import { copyParam, getHref } from '../../util/uri';
import { init as initTypeaheadData } from './autocomplete_typeahead_data';
import {
  setOnUpKeyedCallback,
  setOnQueryChangedCallback,
  setOnDownKeyedCallback
} from './autocomplete_typeahead_callbacks';
import {
  schoolResultsMarkup,
  districtResultsMarkup,
  cityResultsMarkup
} from './autocomplete_typeahead_markup';
import { isAddress } from './search';

const init = function(state_abbr) {
  attachAutocomplete(state_abbr);
  attachAutocompleteHandlers();
};

const detachAutocomplete = function() {
  $('.typeahead').typeahead('destroy');
  $('.typeahead-nav').typeahead('destroy');
};

const cleardataSetBloodhounds = function (dataSets) {
  for (let i = 0; i < dataSets.length; i++) {
    let dataSet = dataSets[i];
    dataSet.clearBloodhound();
  }
}

const attachAutocomplete = function (state_abbr) {
  let state_query = typeof state_abbr === "string" ? '&state=' + state_abbr : '';
  let schools = initTypeaheadData({tokenizedAttribute: 'school_name', defaultUrl: '/gsr/search/suggest/school?query=%QUERY' + state_query, sortFunction: false });
  let cities = initTypeaheadData({tokenizedAttribute: 'city_name', defaultUrl: '/gsr/search/suggest/city?query=%QUERY' + state_query, displayLimit: 5 });
  let districts = initTypeaheadData({tokenizedAttribute: 'district_name', defaultUrl: '/gsr/search/suggest/district?query=%QUERY' + state_query, displayLimit: 5 });
  let navSchools = initTypeaheadData({tokenizedAttribute: 'school_name', defaultUrl: '/gsr/search/suggest/school?query=%QUERY', sortFunction: false });
  let navCities = initTypeaheadData({tokenizedAttribute: 'city_name', defaultUrl: '/gsr/search/suggest/city?query=%QUERY', displayLimit: 5 });
  let navDistricts = initTypeaheadData({tokenizedAttribute: 'district_name', defaultUrl: '/gsr/search/suggest/district?query=%QUERY', displayLimit: 5 });

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
      templates: cityResultsMarkup()
    },
    {
      name: 'districts',
      displayKey: 'district_name',
      source: navDistricts.ttAdapter(),
      clearBloodhound: navDistricts.ttAdapterClear(),
      templates: districtResultsMarkup()
    },
    {
      name: 'schools',
      displayKey: 'school_name',
      source: navSchools.ttAdapter(),
      clearBloodhound: navSchools.ttAdapterClear(),
      templates: schoolResultsMarkup()
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
      templates: cityResultsMarkup()
    },
    {
      name: 'districts',
      displayKey: 'district_name',
      source: districts.ttAdapter(),
      clearBloodhound: districts.ttAdapterClear(),
      templates: districtResultsMarkup()
    },
    {
      name: 'schools',
      displayKey: 'school_name',
      source: schools.ttAdapter(),
      clearBloodhound: schools.ttAdapterClear(),
      templates: schoolResultsMarkup()
    }
  );
};

var attachAutocompleteHandlers = function() {
  setOnUpKeyedCallbackForSearch();
  setOnQueryChangedCallbackForSearch();
  setOnDownKeyedCallbackForSearch();
};

var setOnUpKeyedCallbackForSearch = function() {
  setOnUpKeyedCallback(function(query) {

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
  setOnDownKeyedCallback(function(query) {
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
  setOnQueryChangedCallback(function(query) {

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

export {
  init,
  detachAutocomplete
}
