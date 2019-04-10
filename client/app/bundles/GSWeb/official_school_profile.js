import ReactOnRails from 'react-on-rails';
import OspSearchBox from 'react_components/osp_search_box';
import SearchBox from 'react_components/search_box';
import withViewportSize from 'react_components/with_viewport_size';
import commonPageInit from './common';

const SearchBoxWrapper = withViewportSize({ propName: 'size' })(SearchBox);
ReactOnRails.register({
  OspSearchBox,
  SearchBoxWrapper,
})

$(commonPageInit);

