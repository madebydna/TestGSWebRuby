import 'core-js/es6/set';
import 'core-js/fn/array/find';
import ReactOnRails from 'react-on-rails';
import SearchBox from 'react_components/search_box';
import withViewportSize from 'react_components/with_viewport_size';

const SearchBoxWrapper = withViewportSize({ propName: 'size' })(SearchBox);

ReactOnRails.register({
  SearchBoxWrapper
});

$(() => {
  ReactOnRails.reactOnRailsPageLoaded();
});

export default SearchBoxWrapper;
