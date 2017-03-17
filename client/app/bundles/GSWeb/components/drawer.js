import checkRequiredProps from '../util/checkRequiredProps';
import Toggle from './toggle';
// TODO: import lodash assign
// TODO: import jquery

export function makeDrawer($container) {
  var toggle = _.assign(new Toggle($container));
  toggle.effect = "slideToggle";
  toggle.addCallback(
    toggle.updateButtonTextCallback(GS.I18n.t('show_less'), GS.I18n.t('show_more'))
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

