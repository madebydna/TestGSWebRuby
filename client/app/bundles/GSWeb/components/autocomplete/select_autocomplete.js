import { init as initTypeaheadData } from './autocomplete_typeahead_data';

const init = function(state_abbr, markupCallback, onSelectCallback ) {
  attachAutocomplete(state_abbr, markupCallback, onSelectCallback);
};

const attachAutocomplete = function (state_abbr, markupCallback, onSelectCallback) {
  let  state_query = typeof state_abbr === "string" ? '&state=' + state_abbr : '';
  let  schools = initTypeaheadData({tokenizedAttribute: 'school_name', defaultUrl: '/gsr/search/suggest/school?query=%QUERY' + state_query, sortFunction: false });
  $('.typeahead-school-picker').typeahead({
    hint: true,
    highlight: true,
    minLength: 1
  },
    {
      name: 'schools',
      displayKey: 'school_name',
      source: schools.ttAdapter(),
      clearBloodhound: schools.ttAdapterClear(),
      templates: markupCallback.call()
    }
  ).on('typeahead:selected', onSelectCallback );
};

export { init }
