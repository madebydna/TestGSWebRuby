import 'core-js/es6/set';
import 'core-js/fn/array/find';
import ReactOnRails from 'react-on-rails';
import configureStore from './store/appStore';
import Search from './react_components/search/search';
import * as tooltips from './util/tooltip';
import * as remodal from './util/remodal';
import './vendor/tipso';
import { init as initHeader } from './header';

window.store = configureStore({
  search: gon.search
});

ReactOnRails.register({
  Search
});

$(function() {
  initHeader();
  ReactOnRails.reactOnRailsPageLoaded();
  tooltips.initialize();
  remodal.init();
});
