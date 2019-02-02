import ReactOnRails from 'react-on-rails';
import * as tooltips from './util/tooltip';
import * as remodal from './util/remodal';
import AccountContext from './react_components/account/account_context';
import './vendor/tipso';
import { init as initHeader } from './header';

ReactOnRails.register({ AccountContext });

$(() => {
  initHeader();
  ReactOnRails.reactOnRailsPageLoaded();
  tooltips.initialize();
  remodal.init();
});
