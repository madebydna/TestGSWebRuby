import ReactOnRails from 'react-on-rails';
import Search from './react_components/search/search';
import * as tooltips from './util/tooltip';
import * as remodal from './util/remodal';
import './vendor/tipso';
import { init as initHeader } from './header';

ReactOnRails.register({
  Search
});

$(function() {
  initHeader();
  ReactOnRails.reactOnRailsPageLoaded();
  tooltips.initialize();
  remodal.init();
});
