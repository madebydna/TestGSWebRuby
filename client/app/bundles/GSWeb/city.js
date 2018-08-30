import ReactOnRails from 'react-on-rails';
import City from './react_components/community/city';
import District from './react_components/community/district'
import * as tooltips from './util/tooltip';
import * as remodal from './util/remodal';
import './vendor/tipso';
import { init as initHeader } from './header';

ReactOnRails.register({
  City, District
});

$(() => {
  initHeader();
  ReactOnRails.reactOnRailsPageLoaded();
  tooltips.initialize();
  remodal.init();
});
