import ReactOnRails from 'react-on-rails';
import ReviewSchoolPicker from 'react_components/review_school_picker';
import ReviewPageAlternateSelector from 'react_components/review_page_alternate_selector';
import ReviewPageSearchBox from 'react_components/review_page_search_box'
import SearchBox from 'react_components/search_box';
import withViewportSize from 'react_components/with_viewport_size';
import commonPageInit from './common';

const SearchBoxWrapper = withViewportSize({ propName: 'size' })(SearchBox);
ReactOnRails.register({
  ReviewSchoolPicker,
  ReviewPageSearchBox,
  ReviewPageAlternateSelector,
  SearchBoxWrapper,
})

$(commonPageInit);

