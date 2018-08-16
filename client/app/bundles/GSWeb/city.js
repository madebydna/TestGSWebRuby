import ReactOnRails from 'react-on-rails';
import configureStore from './store/appStore';
import City from './react_components/community/city';
import * as tooltips from './util/tooltip';
import * as remodal from './util/remodal';
import './vendor/tipso';
import { init as initHeader } from './header';

window.store = configureStore({
  search: gon.city
});

ReactOnRails.register({
  City
});

$(() => {
  initHeader();
  ReactOnRails.reactOnRailsPageLoaded();
  tooltips.initialize();
  remodal.init();
});
