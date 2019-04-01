import ReactOnRails from 'react-on-rails';
import ReviewPageSearchBox from 'react_components/review_page_search_box';
import SearchBox from 'react_components/search_box';
import withViewportSize from 'react_components/with_viewport_size';
import commonPageInit from './common';

const SearchBoxWrapper = withViewportSize({ propName: 'size' })(SearchBox);
ReactOnRails.register({
  ReviewPageSearchBox,
  SearchBoxWrapper,
})

$(commonPageInit);

