import './util/advertising';
import { initInterstitialPage } from './components/interstitial';
import { init as initAdvertising } from 'util/advertising';

initInterstitialPage();
$(window).on('load', function() {
  initAdvertising();
});
