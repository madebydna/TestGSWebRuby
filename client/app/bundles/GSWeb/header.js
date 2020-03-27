import { init as menuInit } from './components/header/menu'
import { init as searchBarInit } from './components/header/search_bar'
import { init as featuredInit } from './components/header/featured'
import { init as languageInit } from './components/header/language_links'
import { init as searchAutocompleteInit } from './components/autocomplete/search_autocomplete';
import { init as searchInit } from './components/autocomplete/search';
import { init as googleMapsInit } from 'components/map/google_maps';
import { init as toastInit } from 'components/header/toast';

import './vendor/typeahead_modified.bundle';

const init = function({includeFeatured = true} = {}) {
  if ( document.getElementsByClassName("header_un").length > 0 ) {
    menuInit();
    searchBarInit();
    if(includeFeatured) {
      featuredInit();
    }
    languageInit();
    searchInit();
    googleMapsInit(searchAutocompleteInit);
    toastInit();
  }
}

export { init }
