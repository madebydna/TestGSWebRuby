import ReactOnRails from 'react-on-rails';
import SearchBox from 'react_components/search_box';
import withViewportSize from 'react_components/with_viewport_size';
import commonPageInit from './common';

// ? This file handles loading what's needed for any page
// ? that uses our "new" layouts with solr7 autosuggest in
// ? header etc. You can use this if you dont need anything
// ? more specific. Otherwise create a new file for your page

const SearchBoxWrapper = withViewportSize({ propName: 'size' })(SearchBox);
ReactOnRails.register({
  SearchBoxWrapper,
})

$(commonPageInit);

