import ReactOnRails from 'react-on-rails';
import Widget from './react_components/widget';
import { init as initHeader } from './header';

ReactOnRails.register({
  Widget
});
ReactOnRails.reactOnRailsPageLoaded();

$(function() {
  initHeader();
});
