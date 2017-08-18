import checkRequiredProps from '../util/checkRequiredProps';
import Toggle from './toggle';
import { t } from '../util/i18n';
import { assign } from 'lodash';
// TODO: import jquery

export function makeDrawer($container) {
  var toggle = assign(new Toggle($container));
  toggle.effect = "slideToggle";
  toggle.addCallback(
    toggle.updateButtonTextCallback(t('show_less'), t('show_more'))
  );
  toggle.addCallback(
    toggle.updateContainerClassCallback('show-more--open','show-more--closed')
  );
  toggle.addCallback(
      toggle.sendGoogleAnalyticsCallback('ga-category', 'ga-label')
  );
  return toggle.init();
}

export function makeDrawersWithSelector(selector) {
  $(selector).each(function() {
    makeDrawer($(this)).add_onclick();
  });
};

