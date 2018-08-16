import ReactOnRails from 'react-on-rails';
import configureStore from './store/appStore';
import City from './react_components/community/city';
import * as tooltips from './util/tooltip';
import * as remodal from './util/remodal';
import './vendor/tipso';
import { init as initHeader } from './header';
import SearchBox from 'react_components/search_box';
import withViewportSize from 'react_components/with_viewport_size';

const SearchBoxWrapper = withViewportSize({ propName: 'size' })(SearchBox);

// window.store = configureStore({
//   city: gon.city
// });

ReactOnRails.register({
  City,
  SearchBoxWrapper
});

$(() => {
  initHeader();
  ReactOnRails.reactOnRailsPageLoaded();
  tooltips.initialize();
  remodal.init();
});
