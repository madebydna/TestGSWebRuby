import './vendor/remodal'; // needed for modals, such as newsletter modals launched by link in footer
import ReactOnRails from 'react-on-rails';
import * as tooltips from './util/tooltip';
import * as remodal from './util/remodal';
import './vendor/tipso';
import { init as initHeader } from './header';
import * as footer from 'components/footer';

const commonPageInit = ({includeFeatured} = {}) => {
  initHeader();
  ReactOnRails.reactOnRailsPageLoaded();
  tooltips.initialize();
  remodal.init();
  footer.setupNewsletterLink();
}
export default commonPageInit;