import { init as menuInit } from './components/header/menu'
import { init as searchBarInit } from './components/header/search_bar'
import { init as featuredInit } from './components/header/featured'
import { init as languageInit } from './components/header/language_links'
import { init as searchAutocompleteInit } from './components/autocomplete/search_autocomplete';

import './vendor/typeahead_modified.bundle';

const init = function() {
  if ( document.getElementsByClassName("header_un").length > 0 ) {
    menuInit();
    searchBarInit();
    featuredInit();
    languageInit();
    searchAutocompleteInit();
  }
}

export { init }
