import ReactOnRails from 'react-on-rails';
import configureStore from './store/appStore';
import MySchoolList from './react_components/my_school_list';
import * as tooltips from './util/tooltip';
import * as remodal from './util/remodal';
import './vendor/tipso';
import { init as initHeader } from './header';

window.store = configureStore({
  search: gon.search
});

ReactOnRails.register({
  MySchoolList
});

$(() => {
  initHeader();
  ReactOnRails.reactOnRailsPageLoaded();
  tooltips.initialize();
  remodal.init();
});
