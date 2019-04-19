import ReactOnRails from 'react-on-rails';
import withViewportSize from 'react_components/with_viewport_size';
import SearchBox from 'react_components/search_box';
import Widget from './react_components/widget';
import commonPageInit from './common';

const SearchBoxWrapper = withViewportSize({ propName: 'size' })(SearchBox);
ReactOnRails.register({
  SearchBoxWrapper,
  Widget
});

$(commonPageInit);
