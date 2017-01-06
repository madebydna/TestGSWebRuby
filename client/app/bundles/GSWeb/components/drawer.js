import checkRequiredProps from '../util/checkRequiredProps';
import Toggle from './toggle';
// TODO: import lodash assign
// TODO: import jquery

export function makeDrawer($container) {
  var toggle = _.assign(new Toggle($container));
  toggle.effect = "slideToggle";
  toggle.addCallback(
    toggle.updateButtonTextCallback('Show Less', 'Show More')
  );
  toggle.addCallback(
    toggle.updateContainerClassCallback('show-more--open','show-more--closed')
  );
  return toggle.init();
}

export function makeDrawersWithSelector(selector) {
  $(selector).each(function() {
    makeDrawer($(this)).add_onclick();
  });
};

