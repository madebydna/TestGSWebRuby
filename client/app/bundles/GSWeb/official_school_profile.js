import ReactOnRails from 'react-on-rails';
import SearchBox from 'react_components/search_box';
import withViewportSize from 'react_components/with_viewport_size';
import commonPageInit from './common';
import ReviewSchoolPicker from "./react_components/review_school_picker";
import ReviewPageSearchBox from "./react_components/review_page_search_box";
import ReviewPageAlternateSelector from "./react_components/review_page_alternate_selector";

const SearchBoxWrapper = withViewportSize({ propName: 'size' })(SearchBox);
ReactOnRails.register({
  ReviewSchoolPicker,
  ReviewPageSearchBox,
  ReviewPageAlternateSelector,
  SearchBoxWrapper,
})

$(commonPageInit);

